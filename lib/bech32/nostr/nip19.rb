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

      # Maximum length of a NIP-19 string (NIP-19: "SHOULD be limited in size to 5000 characters").
      MAX_LENGTH = 5000

      module_function

      # Decode nip19 string.
      # @param [String] string Bech32 string.
      # @return [BareEntity]
      # @return [TLVEntity]
      # @raise [ArgumentError] if the string is invalid or longer than MAX_LENGTH characters.
      def decode(string)
        raise ArgumentError, 'nip19 string must be String.' unless string.is_a?(String)
        raise ArgumentError, "nip19 string must be at most #{MAX_LENGTH} characters." if string.length > MAX_LENGTH
        hrp, data, spec = Bech32.decode(string, MAX_LENGTH)

        raise ArgumentError, 'Invalid nip19 string.' if hrp.nil?
        raise ArgumentError, 'Invalid bech32 spec.' unless spec == Bech32::Encoding::BECH32

        converted = Bech32.convert_bits(data, 5, 8, false)
        raise ArgumentError, 'Invalid data.' if converted.nil?
        entity = converted.pack('C*')
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