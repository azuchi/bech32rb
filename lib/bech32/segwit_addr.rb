module Bech32

  class SegwitAddr

    HRP_MAINNET = 'bc'
    HRP_TESTNET = 'tb'
    HRP_REGTEST = 'bcrt'

    attr_accessor :hrp # human-readable part
    attr_accessor :ver # witness version
    attr_accessor :prog # witness program

    def initialize(addr = nil)
      @hrp = HRP_MAINNET
      parse_addr(addr) if addr
    end

    # Returns segwit script pubkey which generated from witness version and witness program.
    def to_script_pubkey
      v = ver == 0 ? ver : ver + 0x50
      ([v, prog.length] + prog).pack('C*').unpack("H*").first
    end

    # parse script pubkey into witness version and witness program
    def script_pubkey=(script_pubkey)
      values = [script_pubkey].pack('H*').unpack("C*")
      @ver = values[0] == 0 ? values[0] : values[0] - 0x50
      @prog = values[2..-1]
    end

    # Returns segwit address string which generated from hrp, witness version and witness program.
    def addr
      spec = (ver == 0 ? Bech32::Encoding::BECH32 : Bech32::Encoding::BECH32M)
      Bech32.encode(hrp, [ver] + Bech32.convert_bits(prog, 8, 5), spec)
    end

    private

    def parse_addr(addr)
      @hrp, data, spec = Bech32.decode(addr)
      raise 'Invalid address.' if hrp.nil? || data[0].nil? || ![HRP_MAINNET, HRP_TESTNET, HRP_REGTEST].include?(hrp)
      @ver = data[0]
      raise 'Invalid witness version' if @ver > 16
      @prog = Bech32.convert_bits(data[1..-1], 5, 8, false)
      raise 'Invalid witness program' if @prog.nil? || @prog.length < 2 || @prog.length > 40
      raise 'Invalid witness program with version 0' if @ver == 0 && (@prog.length != 20 && @prog.length != 32)
      raise 'Witness version and encoding spec do not match' if (@ver == 0 && spec != Bech32::Encoding::BECH32) || (@ver != 0 && spec != Bech32::Encoding::BECH32M)
    end

  end
end