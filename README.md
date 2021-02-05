# Bech32 [![Build Status](https://travis-ci.org/azuchi/bech32rb.svg?branch=master)](https://travis-ci.org/azuchi/bech32rb) [![Gem Version](https://badge.fury.io/rb/bech32.svg)](https://badge.fury.io/rb/bech32) [![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE) <img src="http://segwit.co/static/public/images/logo.png" width="100">

The implementation of the Bech32/Bech32m encoder and decoder for Ruby.

Bech32 is checksummed base32 format that is used in following Bitcoin address format.

https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki

Bech32m is checksummed base32m format that is used in following Bitcoin address format.

https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bech32'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bech32

## Usage

Require the Gem:

```ruby
require 'bech32'
```

### Decode

Decode Bech32-encoded data into hrp part and data part.

```ruby
hrp, data, spec = Bech32.decode('BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4')

# hrp is human-readable part of Bech32 format
'bc'

# data is data part of Bech32 format
[0, 14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13, 8, 21, 4, 20, 3, 17, 2, 29, 3, 12, 29, 3, 4, 15, 24, 20, 6, 14, 30, 22]

# spec is whether Bech32::Encoding::BECH32 or Bech32::Encoding::BECH32M
```

Decode Bech32-encoded Segwit address into `Bech32::SegwitAddr` instance.

```ruby
addr = 'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4'
segwit_addr = Bech32::SegwitAddr.new(addr)

# generate script pubkey
segwit_addr.to_script_pubkey
=> 0014751e76e8199196d454941c45d1b3a323f1433bd6
```

#### Advanced

The maximum number of characters of Bech32 defined in [BIP-173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki) is limited to 90 characters.
However, LN specification [BOLT#11](https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md) has no limitation.

To decode data of more than 90 characters, specify `max_length` at decode as below. (The default value of `max_length` is 90.)

```ruby
MAX_INTEGER = 2**31 - 1
Bech32.decode(bechString, MAX_INTEGER)
```

Note that between length of the addresses and the error-detection capabilities are [trade-off](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#checksum-design).

### Encode

Encode Bech32 human-readable part and data part into Bech32 string.

```ruby
hrp = 'bc'
data = [0, 14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13, 8, 21, 4, 20, 3, 17, 2, 29, 3, 12, 29, 3, 4, 15, 24, 20, 6, 14, 30, 22]

bech = Bech32.encode(hrp, data, Bech32::Encoding::BECH32)
=> bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4
```

Encode Segwit script into Bech32 Segwit address.

```ruby
segwit_addr = Bech32::SegwitAddr.new
segwit_addr.script_pubkey = '0014751e76e8199196d454941c45d1b3a323f1433bd6'

# generate addr
segwit_addr.addr
=> bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

