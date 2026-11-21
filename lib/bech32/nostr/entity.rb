require 'stringio'

module Bech32
  module Nostr
    class BareEntity
      attr_reader :hrp
      attr_reader :data

      # Initialize bare entity.
      # @param [String] hrp human-readable part.
      # @param [String] data Entity data(hex string).
      def initialize(hrp, data)
        raise ArgumentError, "HRP #{hrp} is unsupported." unless NIP19::BARE_PREFIXES.include?(hrp)
        raise ArgumentError, "Data whose HRP is #{hrp} must be 32 bytes." unless [data].pack('H*').bytesize == 32
        @hrp = hrp
        @data = data
      end

      # Encode bare entity to bech32 string.
      # @return [String] bech32 string.
      def encode
        Bech32.encode(hrp, Bech32.convert_bits([data].pack('H*').unpack('C*'), 8, 5), Bech32::Encoding::BECH32)
      end
    end

    class TLVEntry

      attr_reader :type
      attr_reader :label
      attr_reader :value

      def initialize(type, value, label = nil)
        raise ArgumentError, "Type #{type} unsupported." unless TLVEntity::TYPES.include?(type)
        if type == TLVEntity::TYPE_KIND
          raise ArgumentError, "Value of kind must be Integer. #{value.class} given." unless value.is_a?(Integer)
        else
          raise ArgumentError, "Value of type #{type} must be String. #{value.class} given." unless value.is_a?(String)
        end

        @type = type
        @value = value
        @label = label
      end

      # Maximum byte length of a TLV value (the length field is 1 byte).
      MAX_VALUE_LENGTH = 255

      # Convert to binary data.
      # @param [String] hrp human-readable part of the entity this entry belongs to.
      # It determines whether a special entry's value is a hex string (nprofile, nevent)
      # or a raw string (nrelay, naddr). If omitted, a special value is treated as hex
      # only when it looks like a hex string.
      # @return [String] binary data.
      # @raise [ArgumentError] if the value is out of range or longer than MAX_VALUE_LENGTH bytes.
      def to_payload(hrp = nil)
        data = if value.is_a?(Integer)
                 unless value.between?(0, 0xffffffff)
                   raise ArgumentError, "Integer value must be between 0 and #{0xffffffff}."
                 end
                 [value].pack('N')
               elsif hex_value?(hrp)
                 raise ArgumentError, "Value of type #{type} must be a hex string." unless hex_string?(value)
                 [value].pack('H*')
               else
                 value.b
               end
        len = data.bytesize
        raise ArgumentError, "Value must be at most #{MAX_VALUE_LENGTH} bytes." if len > MAX_VALUE_LENGTH
        [type, len].pack('CC') + data
      end

      def to_s
        type_label = case type
                     when TLVEntity::TYPE_SPECIAL
                       'special'
                     when TLVEntity::TYPE_RELAY
                       'relay'
                     when TLVEntity::TYPE_AUTHOR
                       'author'
                     when TLVEntity::TYPE_KIND
                       'kind'
                     else
                       'unknown'
                     end
        "#{type_label}: #{value}"
      end

      private

      # Check whether the value of this entry is a hex-encoded string.
      # @param [String] hrp human-readable part (may be nil).
      # @return [Boolean]
      def hex_value?(hrp)
        case type
        when TLVEntity::TYPE_AUTHOR
          true
        when TLVEntity::TYPE_SPECIAL
          hrp.nil? ? hex_string?(value) : [NIP19::HRP_PROFILE, NIP19::HRP_EVENT].include?(hrp)
        else
          false
        end
      end

      # Check whether +str+ is hex string or not.
      # @param [String] str string.
      # @return [Boolean]
      def hex_string?(str)
        return false if str.bytes.any? { |b| b > 127 }
        return false if str.length % 2 != 0
        hex_chars = str.chars.to_a
        hex_chars.all? { |c| c =~ /[0-9a-fA-F]/ }
      end
    end

    class TLVEntity

      TYPE_SPECIAL = 0
      TYPE_RELAY = 1
      TYPE_AUTHOR = 2
      TYPE_KIND = 3

      TYPES = [TYPE_SPECIAL, TYPE_RELAY, TYPE_AUTHOR, TYPE_KIND]

      # TLV types each HRP supports. Other types are ignored when parsing (NIP-19).
      SUPPORTED_TYPES = {
        NIP19::HRP_PROFILE => [TYPE_SPECIAL, TYPE_RELAY].freeze,
        NIP19::HRP_EVENT => [TYPE_SPECIAL, TYPE_RELAY, TYPE_AUTHOR, TYPE_KIND].freeze,
        NIP19::HRP_RELAY => [TYPE_SPECIAL].freeze,
        NIP19::HRP_EVENT_COORDINATE => [TYPE_SPECIAL, TYPE_RELAY, TYPE_AUTHOR, TYPE_KIND].freeze
      }.freeze

      # TLV types each HRP requires (NIP-19).
      REQUIRED_TYPES = {
        NIP19::HRP_PROFILE => [TYPE_SPECIAL].freeze,
        NIP19::HRP_EVENT => [TYPE_SPECIAL].freeze,
        NIP19::HRP_RELAY => [TYPE_SPECIAL].freeze,
        NIP19::HRP_EVENT_COORDINATE => [TYPE_SPECIAL, TYPE_AUTHOR, TYPE_KIND].freeze
      }.freeze

      # Byte length of a public key or an event id (NIP-19).
      KEY_LENGTH = 32

      attr_reader :hrp
      attr_reader :entries

      # Initialize TLV entity.
      # @param [String] hrp human-readable part.
      # @param [Array<TLVEntry>] entries TLV entries.
      # @return [TLVEntity]
      def initialize(hrp, entries)
        raise ArgumentError, "HRP #{hrp} is unsupported." unless NIP19::TLV_PREFIXES.include?(hrp)
        entries.each do |e|
          raise ArgumentError, "Entries must be TLVEntry. #{e.class} given." unless e.is_a?(TLVEntry)
        end

        @hrp = hrp
        @entries = entries
      end

      # Parse TLV entity from data.
      # @param [String] hrp human-readable part.
      # @param [String] data Entity data(binary format).
      # @return [TLVEntity]
      def self.parse(hrp, data)
        supported = SUPPORTED_TYPES.fetch(hrp) { raise ArgumentError, "HRP #{hrp} is unsupported." }
        buf = ::StringIO.new(data)
        entries = []
        until buf.eof?
          header = buf.read(2)
          raise ArgumentError, "Invalid TLV: truncated header." if header.nil? || header.bytesize < 2
          type, len = header.unpack('CC')
          value = buf.read(len)
          raise ArgumentError, "Invalid TLV: truncated value." if value.nil? ? len > 0 : value.bytesize < len
          value ||= ''
          # NIP-19: TLVs that are not recognized or supported should be ignored, rather than causing an error.
          next unless supported.include?(type)

          check_value_length(hrp, type, value.bytesize)
          check_value_encoding(hrp, type, value)

          entries << case type
                     when TYPE_SPECIAL
                       case hrp
                       when NIP19::HRP_PROFILE then TLVEntry.new(type, value.unpack1('H*'), 'pubkey')
                       when NIP19::HRP_RELAY then TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'relay')
                       when NIP19::HRP_EVENT then TLVEntry.new(type, value.unpack1('H*'), 'id')
                       else TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'identifier')
                       end
                     when TYPE_RELAY
                       TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'relay')
                     when TYPE_AUTHOR
                       TLVEntry.new(type, value.unpack1('H*'), 'author')
                     else # TYPE_KIND
                       raise ArgumentError, 'Invalid TLV: kind must be 4 bytes.' unless value.bytesize == 4
                       TLVEntry.new(type, value.unpack1('N'), 'kind')
                     end
        end

        check_required_types(hrp, entries)
        TLVEntity.new(hrp, entries)
      end

      # Encode tlv entity to bech32 string.
      # The entity is checked against the same rules as {.parse}, so that the result can be decoded.
      # @return [String] bech32 string.
      # @raise [ArgumentError] if an entry type is unsupported for the HRP, a value has an invalid length
      # or encoding, or a required entry is missing.
      def encode
        supported = SUPPORTED_TYPES[hrp]
        entries.each do |e|
          raise ArgumentError, "Type #{e.type} is unsupported for HRP: #{hrp}" unless supported.include?(e.type)
        end
        payloads = entries.map { |e| e.to_payload(hrp) }
        entries.zip(payloads) do |e, payload|
          TLVEntity.check_value_length(hrp, e.type, payload.bytesize - 2)
          TLVEntity.check_value_encoding(hrp, e.type, payload.byteslice(2..))
        end
        TLVEntity.check_required_types(hrp, entries)
        data = payloads.join
        Bech32.encode(hrp, Bech32.convert_bits(data.unpack('C*'), 8, 5), Bech32::Encoding::BECH32)
      end

      # Check the byte length of a TLV value.
      # Public keys and event ids must be 32 bytes, and the relay of nrelay must not be empty.
      # @param [String] hrp human-readable part.
      # @param [Integer] type TLV type.
      # @param [Integer] length byte length of the value.
      # @raise [ArgumentError] if the length is invalid.
      def self.check_value_length(hrp, type, length)
        if type == TYPE_AUTHOR || (type == TYPE_SPECIAL && [NIP19::HRP_PROFILE, NIP19::HRP_EVENT].include?(hrp))
          return if length == KEY_LENGTH

          raise ArgumentError, "Invalid TLV: type #{type} for HRP: #{hrp} must be #{KEY_LENGTH} bytes."
        elsif type == TYPE_SPECIAL && hrp == NIP19::HRP_RELAY && length.zero?
          raise ArgumentError, "Invalid TLV: type #{type} for HRP: #{hrp} must not be empty."
        end
      end

      # Check the character encoding of a relay or identifier value.
      # NIP-19: a relay is ASCII. The naddr identifier ("d" tag) must be valid UTF-8.
      # @param [String] hrp human-readable part.
      # @param [Integer] type TLV type.
      # @param [String] value raw value bytes.
      # @raise [ArgumentError] if the encoding is invalid.
      def self.check_value_encoding(hrp, type, value)
        if type == TYPE_RELAY || (type == TYPE_SPECIAL && hrp == NIP19::HRP_RELAY)
          raise ArgumentError, 'Invalid TLV: relay must be ASCII.' unless value.b.ascii_only?
        elsif type == TYPE_SPECIAL && hrp == NIP19::HRP_EVENT_COORDINATE
          unless value.dup.force_encoding(::Encoding::UTF_8).valid_encoding?
            raise ArgumentError, 'Invalid TLV: identifier must be valid UTF-8.'
          end
        end
      end

      # Check that all TLV types required for the HRP are present.
      # @param [String] hrp human-readable part.
      # @param [Array<TLVEntry>] entries TLV entries.
      # @raise [ArgumentError] if a required type is missing.
      def self.check_required_types(hrp, entries)
        REQUIRED_TYPES[hrp].each do |required|
          next if entries.any? { |e| e.type == required }

          raise ArgumentError, "Invalid TLV: missing required type #{required} for HRP: #{hrp}"
        end
      end
    end
  end
end