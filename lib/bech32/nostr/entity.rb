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
        buf = ::StringIO.new(data)
        entries = []
        until buf.eof?
          header = buf.read(2)
          raise ArgumentError, "Invalid TLV: truncated header." if header.nil? || header.bytesize < 2
          type, len = header.unpack('CC')
          value = buf.read(len)
          raise ArgumentError, "Invalid TLV: truncated value." if value.nil? ? len > 0 : value.bytesize < len
          value ||= ''
          case type
          when TYPE_SPECIAL # special
            case hrp
            when NIP19::HRP_PROFILE
              entries << TLVEntry.new(type, value.unpack1('H*'), 'pubkey')
            when NIP19::HRP_RELAY
              entries << TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'relay')
            when NIP19::HRP_EVENT
              entries << TLVEntry.new(type, value.unpack1('H*'), 'id')
            when NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'identifier')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          when TYPE_RELAY # relay
            case hrp
            when NIP19::HRP_PROFILE, NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, value.force_encoding(::Encoding::UTF_8), 'relay')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          when TYPE_AUTHOR # author
            case hrp
            when NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, value.unpack1('H*'), 'author')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          when TYPE_KIND # kind
            case hrp
            when NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              raise ArgumentError, 'Invalid TLV: kind must be 4 bytes.' unless value.bytesize == 4
              entries << TLVEntry.new(type, value.unpack1('N'), 'kind')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          else
            raise ArgumentError, "Unknown TLV type: #{type}"
          end
        end

        TLVEntity.new(hrp, entries)
      end

      # Encode tlv entity to bech32 string.
      # @return [String] bech32 string.
      def encode
        data = entries.map { |e| e.to_payload(hrp) }.join
        Bech32.encode(hrp, Bech32.convert_bits(data.unpack('C*'), 8, 5), Bech32::Encoding::BECH32)
      end
    end
  end
end