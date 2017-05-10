require 'spec_helper'

describe Bech32 do

  VALID_CHECKSUM = [
      "A12UEL5L",
      "an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs",
      "abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw",
      "11qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqc8247j",
      "split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w",
  ]

  VALID_ADDRESS = [
      ["BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4", "0014751e76e8199196d454941c45d1b3a323f1433bd6"],
      ["tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
       "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"],
      ["bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
       "8128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6"],
      ["BC1SW50QA3JX3S", "9002751e"],
      ["bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj", "8210751e76e8199196d454941c45d1b3a323"],
      ["tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
       "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"],
  ]

  INVALID_ADDRESS = [
      "tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty",
      "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5",
      "BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2",
      "bc1rw5uspcuh",
      "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90",
      "BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P",
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7",
      "tb1pw508d6qejxtdg4y5r3zarqfsj6c3",
      "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv",
  ]

  it 'verify checksum' do
    VALID_CHECKSUM.each do |bech|
      hrp, _ = Bech32.decode(bech)
      expect(hrp).to be_truthy
      pos = bech.rindex('1')
      bech = bech[0..pos] + (bech[pos + 1].ord ^ 1).chr + bech[pos+2..-1]
      hrp, _ = Bech32.decode(bech)
      expect(hrp).to be_nil
    end
  end

  it 'valid adress' do
    VALID_ADDRESS.each do |addr, hex|
      segwit_addr = Bech32::SegwitAddr.new(addr)
      expect(segwit_addr.ver).to be_truthy
      expect(segwit_addr.to_script_pubkey).to eq(hex)
      expect(segwit_addr.addr).to eq(addr.downcase)
    end
  end

  it 'invlid address' do
    INVALID_ADDRESS.each do |addr|
      expect{Bech32::SegwitAddr.new(addr)}.to raise_error(RuntimeError)
    end
  end

end
