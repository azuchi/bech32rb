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

      # Convert to binary data.
      # @return [String] binary data.
      def to_payload
        data = if value.is_a?(Integer)
                 [value].pack('N')
               else
                 hex_string?(value) ? [value].pack('H*') : value
               end
        len = data.bytesize
        [type, len].pack('CC') + data
      end

      private

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
        buf = StringIO.new(data)
        entries = []
        until buf.eof?
          type, len = buf.read(2).unpack('CC')
          case type
          when TYPE_SPECIAL # special
            case hrp
            when NIP19::HRP_PROFILE
              entries << TLVEntry.new(type, buf.read(len).unpack1('H*'), 'pubkey')
            when NIP19::HRP_RELAY
              entries << TLVEntry.new(type, buf.read(len), 'relay')
            when NIP19::HRP_EVENT
              entries << TLVEntry.new(type, buf.read(len).unpack1('H*'), 'id')
            when NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, buf.read(len), 'identifier')
            end
          when TYPE_RELAY # relay
            case hrp
            when NIP19::HRP_PROFILE, NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, buf.read(len), 'relay')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          when TYPE_AUTHOR # author
            case hrp
            when NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, buf.read(len).unpack1('H*'), 'author')
            else
              raise ArgumentError, "Type: #{type} does not supported for HRP: #{hrp}"
            end
          when TYPE_KIND # kind
            case hrp
            when NIP19::HRP_EVENT, NIP19::HRP_EVENT_COORDINATE
              entries << TLVEntry.new(type, buf.read(len).unpack1('H*').to_i(16), 'kind')
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
        data = entries.map(&:to_payload).join
        Bech32.encode(hrp, Bech32.convert_bits(data.unpack('C*'), 8, 5), Bech32::Encoding::BECH32)
      end
    end
  end
end