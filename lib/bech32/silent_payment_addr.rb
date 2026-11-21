module Bech32
  # BIP-352 silent payment address.
  # https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki#user-content-Address_encoding
  class SilentPaymentAddr
    HRP_MAINNET = 'sp'
    HRP_TESTNET = 'tsp'

    # Maximum valid version. Version 31 is reserved as invalid by BIP-352.
    MAX_VERSION = 30

    attr_reader :hrp
    attr_reader :version
    attr_reader :scan_key
    attr_reader :spend_key

    # Constructor
    # @param [String] hrp HRP for silent payment address.
    # @param [Integer] version The version of sp address.
    # @param [String] scan_key The scan public key with hex format.
    # @param [String] spend_key The spend public key with hex format.
    def initialize(hrp, version, scan_key, spend_key)
      raise ArgumentError, "hrp must be sp or tsp." unless [HRP_MAINNET, HRP_TESTNET].include?(hrp)
      raise ArgumentError, "version must be Integer." unless version.is_a?(Integer)
      raise ArgumentError, "version must be between 0 and #{MAX_VERSION}." unless version.between?(0, MAX_VERSION)
      raise ArgumentError, "scan_key must be String." unless scan_key.is_a?(String)
      raise ArgumentError, "spend_key must be String." unless spend_key.is_a?(String)
      raise ArgumentError, 'scan_key must be a hex string.' unless Bech32.hex_string?(scan_key)
      raise ArgumentError, 'spend_key must be a hex string.' unless Bech32.hex_string?(spend_key)
      raise ArgumentError, 'scan_key must be 33 bytes.' unless [scan_key].pack('H*').bytesize == 33
      raise ArgumentError, 'spend_key must be 33 bytes.' unless [spend_key].pack('H*').bytesize == 33
      @hrp = hrp
      @version = version
      @scan_key = scan_key
      @spend_key = spend_key
    end

    # Byte length of the data part (scan key + spend key) for version 0.
    KEYS_LENGTH = 66

    # Number of 5-bit groups that cover KEYS_LENGTH bytes.
    KEYS_GROUPS = (KEYS_LENGTH * 8 + 4) / 5

    # Maximum length of an address string recommended by BIP-352.
    MAX_LENGTH = 1023

    # Parse silent payment address.
    # Following BIP-352, the data part of a version 0 address must be exactly 66 bytes.
    # For versions 1 through 30, the first 66 bytes are read and the remaining bytes are discarded,
    # so {#to_s} of such an address does not reproduce the original string if it had extra bytes.
    # @param [String] addr Silent payment address.
    # @return [Bech32::SilentPaymentAddr]
    # @raise [ArgumentError]
    def self.parse(addr)
      raise ArgumentError, "addr must be String." unless addr.is_a?(String)
      raise ArgumentError, "addr must be at most #{MAX_LENGTH} characters." if addr.length > MAX_LENGTH
      hrp, data, spec = Bech32.decode(addr, MAX_LENGTH)
      raise ArgumentError, "addr must be encoded with bech32m." unless spec == Bech32::Encoding::BECH32M
      raise ArgumentError, 'Invalid hrp.' if hrp.nil? || data[0].nil? || ![HRP_MAINNET, HRP_TESTNET].include?(hrp)
      version = data[0]
      if version.zero?
        converted = Bech32.convert_bits(data[1..-1], 5, 8, false)
        raise ArgumentError, "Invalid data." if converted.nil?
        raise ArgumentError, "Invalid key size." unless converted.length == KEYS_LENGTH
      else
        # Convert only the 5-bit groups that cover the first 66 bytes, so that the discarded rest
        # does not need to end on a byte boundary.
        groups = data[1..-1]
        raise ArgumentError, "Invalid key size." if groups.length < KEYS_GROUPS
        converted = Bech32.convert_bits(groups[0...KEYS_GROUPS], 5, 8, true)
        raise ArgumentError, "Invalid data." if converted.nil?
      end
      keys = converted[0...KEYS_LENGTH].pack('C*').unpack1('H*')
      scan = keys[0...66]
      spend = keys[66..-1]
      Bech32::SilentPaymentAddr.new(hrp, version, scan, spend)
    end

    # Get silent payment address.
    # @return [String]
    def to_s
      keys = scan_key + spend_key
      data = [keys].pack('H*').unpack('C*')
      Bech32.encode(hrp, [version] + Bech32.convert_bits(data, 8, 5), Bech32::Encoding::BECH32M)
    end

  end
end