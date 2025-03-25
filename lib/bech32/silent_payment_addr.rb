module Bech32
  # BIP-352 silent payment address.
  # https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki#user-content-Address_encoding
  class SilentPaymentAddr
    HRP_MAINNET = 'sp'
    HRP_TESTNET = 'tsp'

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
      raise ArgumentError, "scan_key must be String." unless scan_key.is_a?(String)
      raise ArgumentError, "spend_key must be String." unless spend_key.is_a?(String)
      raise ArgumentError, 'scan_key must be 33 bytes.' unless [scan_key].pack('H*').bytesize == 33
      raise ArgumentError, 'spend_key must be 33 bytes.' unless [spend_key].pack('H*').bytesize == 33
      @hrp = hrp
      @version = version
      @scan_key = scan_key
      @spend_key = spend_key
    end

    # Parse silent payment address.
    # @param [String] addr Silent payment address.
    # @return [Bech32::SilentPaymentAddr]
    # @raise [ArgumentError]
    def self.parse(addr)
      raise ArgumentError, "addr must be String." unless addr.is_a?(String)
      hrp, data, spec = Bech32.decode(addr, addr.length)
      raise ArgumentError, "addr must be encoded with bech32m." unless spec == Bech32::Encoding::BECH32M
      raise ArgumentError, 'Invalid hrp.' if hrp.nil? || data[0].nil? || ![HRP_MAINNET, HRP_TESTNET].include?(hrp)
      version = data[0]
      keys = Bech32.convert_bits(data[1..-1], 5, 8, false).pack('C*').unpack1('H*')
      raise ArgumentError, "Invalid key size." unless keys.length == 132
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