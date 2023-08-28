require "stringio"

module Bech32
  module Nostr
    module NIP19

      HRP_PUBKEY = 'npub'
      HRP_PRIVATE_KEY = 'nsec'
      HRP_NOTE_ID = 'note'
      HRP_PROFILE = 'nprofile'
      HRP_EVENT = 'nevent'
      HRP_RELAY = 'nrelay'
      HRP_EVENT_COORDINATE = 'naddr'

      BARE_PREFIXES = [HRP_PUBKEY, HRP_PRIVATE_KEY, HRP_NOTE_ID]
      TLV_PREFIXES = [HRP_PROFILE, HRP_EVENT, HRP_RELAY, HRP_EVENT_COORDINATE]
      ALL_PREFIXES = BARE_PREFIXES + TLV_PREFIXES

      module_function

      # Decode nip19 string.
      # @param [String] string Bech32 string.
      # @return [BareEntity]
      # @return [TLVEntity]
      def decode(string)
        hrp, data, spec = Bech32.decode(string, string.length)

        raise ArgumentError, 'Invalid nip19 string.' if hrp.nil?
        raise ArgumentError, 'Invalid bech32 spec.' unless spec == Bech32::Encoding::BECH32

        entity = Bech32.convert_bits(data, 5, 8, false).pack('C*')
        raise ArgumentError, "Data whose HRP is #{hrp} must be 32 bytes." if BARE_PREFIXES.include?(hrp) && entity.bytesize != 32
        if BARE_PREFIXES.include?(hrp)
          BareEntity.new(hrp, entity.unpack1('H*'))
        elsif TLV_PREFIXES.include?(hrp)
          TLVEntity.parse(hrp, entity)
        else
          raise ArgumentError, "HRP #{hrp} is unsupported."
        end
      end

    end
  end
end