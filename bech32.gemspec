# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bech32/version'

Gem::Specification.new do |spec|
  spec.name          = "bech32"
  spec.version       = Bech32::VERSION
  spec.authors       = ["Shigeyuki Azuchi"]
  spec.email         = ["azuchi@haw.co.jp"]

  spec.summary       = %q{The implementation of Bech32 encoder and decoder.}
  spec.description   = %q{The implementation of Bech32 encoder and decoder.}
  spec.homepage      = "https://github.com/azuchi/bech32rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end