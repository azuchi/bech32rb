require 'spec_helper'

RSpec.describe Bech32::SilentPaymentAddr do

  it do
    sp_addr = 'sp1qqgste7k9hx0qftg6qmwlkqtwuy6cycyavzmzj85c6qdfhjdpdjtdgqjuexzk6murw56suy3e0rd2cgqvycxttddwsvgxe2usfpxumr70xc9pkqwv'
    addr = described_class.parse(sp_addr)
    expect(addr.hrp).to eq('sp')
    expect(addr.version).to eq(0)
    expect(addr.scan_key).to eq('0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4')
    expect(addr.spend_key).to eq('025cc9856d6f8375350e123978daac200c260cb5b5ae83106cab90484dcd8fcf36')
    expect(addr.to_s).to eq(sp_addr)

    # Invalid addr
    expect{described_class.parse(
      'bc11qqgste7k9hx0qftg6qmwlkqtwuy6cycyavzmzj85c6qdfhjdpdjtdgqjuexzk6murw56suy3e0rd2cgqvycxttddwsvgxe2usfpxumr70xcwnl4nh')}.
      to raise_error(ArgumentError, 'Invalid hrp.')
    expect{ described_class.parse(nil) }.to raise_error(ArgumentError, 'addr must be String.')
    expect{ described_class.parse('5HxWvvfubhXpYYpS3tJkw6fq9jE9j18THftkZjHHfmFiWtmAbrj') }.to raise_error(ArgumentError, 'addr must be encoded with bech32m.')
    expect{ described_class.parse('sp1qqgste7k9hx0qftg6qmwlkqtwuy6cycyavzmzj85c6qdfhjdpdjtdgmqv4xr') }.
      to raise_error(ArgumentError, 'Invalid key size.')

    expect{described_class.new(
      'sp', 0, '', '0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4')}.
      to raise_error(ArgumentError, 'scan_key must be 33 bytes.')
    expect{described_class.new(
      'sp', 0, '0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4', '')}.
      to raise_error(ArgumentError, 'spend_key must be 33 bytes.')
    expect{described_class.new(
      'sp', '0', '0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4', '0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4')}.
      to raise_error(ArgumentError, 'version must be Integer.')
  end

  describe 'version' do
    let(:scan_key) { '0220bcfac5b99e04ad1a06ddfb016ee13582609d60b6291e98d01a9bc9a16c96d4' }
    let(:spend_key) { '025cc9856d6f8375350e123978daac200c260cb5b5ae83106cab90484dcd8fcf36' }

    it 'rejects versions outside 0..30' do
      [-1, 31, 32].each do |version|
        expect{described_class.new('sp', version, scan_key, spend_key)}.
          to raise_error(ArgumentError, 'version must be between 0 and 30.')
      end
    end

    it 'round-trips the maximum version' do
      addr = described_class.new('sp', 30, scan_key, spend_key)
      parsed = described_class.parse(addr.to_s)
      expect(parsed.version).to eq(30)
      expect(parsed.to_s).to eq(addr.to_s)
    end

    it 'rejects an address with version 31' do
      # Build a bech32m string with version 31 directly, bypassing the constructor.
      data = [31] + Bech32.convert_bits([scan_key + spend_key].pack('H*').unpack('C*'), 8, 5)
      addr = Bech32.encode('sp', data, Bech32::Encoding::BECH32M)
      expect{described_class.parse(addr)}.to raise_error(ArgumentError, 'version must be between 0 and 30.')
    end
  end
end