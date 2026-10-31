require 'spec_helper'
require 'open3'

RSpec.describe 'bech32 CLI' do
  EXE = File.expand_path('../exe/bech32', __dir__)
  LIB = File.expand_path('../lib', __dir__)

  def run_cli(*args)
    Open3.capture3(RbConfig.ruby, '-I', LIB, EXE, *args)
  end

  describe 'encode' do
    it 'encodes data' do
      out, _, status = run_cli('encode', 'bc', '00', 'bech32m')
      expect(status.success?).to be true
      expect(out.strip).to eq('bc1qs73yx7')
    end

    it 'fails on invalid type' do
      out, _, status = run_cli('encode', 'bc', '00', 'bech32x')
      expect(status.exitstatus).to eq(1)
      expect(out.strip).to eq('Invalid type value. type must be bech32 or bech32m.')
    end

    it 'fails on invalid hrp without a stack trace' do
      out, err, status = run_cli('encode', 'BC', '00', 'bech32')
      expect(status.exitstatus).to eq(1)
      expect(out.strip).to eq('Can not encode: hrp must consist of lowercase characters in the range 33-126.')
      expect(err).not_to match(/(ArgumentError|RuntimeError|:in ')/)
    end
  end

  describe 'decode' do
    it 'decodes a segwit address' do
      out, _, status = run_cli('decode', 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4')
      expect(status.success?).to be true
      expect(out).to include('HRP: bc', 'WITNESS VERSION: 0', 'WITNESS PROGRAM: 751e76e8199196d454941c45d1b3a323f1433bd6')
    end

    it 'fails on invalid checksum' do
      out, _, status = run_cli('decode', 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5')
      expect(status.exitstatus).to eq(1)
      expect(out.strip).to eq('Can not decode.')
    end

    it 'fails on an invalid segwit program without a stack trace' do
      out, err, status = run_cli('decode', 'bc1pw5dgrnzv')
      expect(status.exitstatus).to eq(1)
      expect(out.strip).to end_with('Can not decode: Invalid witness program')
      expect(err).not_to match(/(ArgumentError|RuntimeError|:in ')/)
    end

    it 'fails on an invalid nip19 entity without a stack trace' do
      out, err, status = run_cli('decode', 'npub1qdl8a8zz4ydlauvl4y57tldpkuhqa0q6fsg5zee7y72zxnvx4h05uk8223u')
      expect(status.exitstatus).to eq(1)
      expect(out.strip).to end_with('Can not decode: Data whose HRP is npub must be 32 bytes.')
      expect(err).not_to match(/(ArgumentError|RuntimeError|:in ')/)
    end
  end
end
