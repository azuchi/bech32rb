require 'spec_helper'
require 'open3'

RSpec.describe Bech32::Nostr::TLVEntity do
  describe '.parse' do
    it 'works before NIP19 is loaded' do
      # Run in a fresh process so that autoload of NIP19 (which also requires stringio) has not fired yet.
      lib = File.expand_path('../../../lib', __dir__)
      script = 'e = Bech32::Nostr::TLVEntity.parse("nrelay", [0, 5].pack("CC") + "wss:/"); print e.entries[0].value'
      out, err, status = Open3.capture3(RbConfig.ruby, '-I', lib, '-r', 'bech32', '-e', script)
      expect(status.success?).to be(true), err
      expect(out).to eq('wss:/')
    end
  end
end
