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
end