# Bech32 [![Build Status](https://github.com/azuchi/bech32rb/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/azuchi/bech32rb/actions/workflows/main.yml) [![Gem Version](https://badge.fury.io/rb/bech32.svg)](https://badge.fury.io/rb/bech32) [![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE) <img src="http://segwit.co/static/public/images/logo.png" width="100">

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
=> 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
```

### Segwit

Decode Bech32-encoded Segwit address into `Bech32::SegwitAddr` instance.

```ruby
addr = 'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4'
segwit_addr = Bech32::SegwitAddr.new(addr)

# generate script pubkey
segwit_addr.to_script_pubkey
=> '0014751e76e8199196d454941c45d1b3a323f1433bd6'
```

Encode Segwit script into Bech32 Segwit address.

```ruby
segwit_addr = Bech32::SegwitAddr.new
segwit_addr.script_pubkey = '0014751e76e8199196d454941c45d1b3a323f1433bd6'

# generate addr
segwit_addr.addr
=> 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'
```

### Nostr

Supports encoding/decoding of Nostr's [NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md) entities.

```ruby
# Decode bare entity
bech32 = 'npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg'
entity = Bech32::Nostr::NIP19.parse(bech32)
entity.hrp
=> 'npub'
entity.data
=> '7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e'

# Decode tlv entity
bech32 = 'nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p'
entity = Bech32::Nostr::NIP19.parse(bech32)
entity.hrp
=> 'nprofile'
entity.entries[0].value
=> '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d'
entity.entries[1].value
=> 'wss://r.x.com'

# Encode bare entity
entity = Bech32::Nostr::BareEntity.new('npub', '7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e')
entity.encode
=> 'npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg'

# Encode tlv entity
entry_relay = Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_RELAY, 'wss://relay.nostr.example')
entry_author = Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, '97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322')
entity = Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, [entry_relay, entry_author])
entity.encode
=> 'nevent1qyvhwumn8ghj7un9d3shjtnwdaehgu3wv4uxzmtsd3jsygyhcu9ygdn2v56uz3dnx0uh865xmlwz675emfsccsxxguz6mx8rygstv78u'
```

### CLI

After installing the gem, the `bech32` command will be available. Encoding and decoding features are also available in the cli. 

#### Encode

The `encode` command takes `HRP`, `data`, and type (`bech32` or `bech32m`) as arguments and outputs a bech32/bech32m string.

    $ bech32 encode genesis 000409190707111719041a120308120a060c161408110d091b090009021b1e1d150e190215010d0a1603091e1f0b100609090d1a1c1a13030c120c0c0f1c020d1d1a0e170b1c17021018121e0a021c121a1c0d161b16131d1609130f1d13180f1e081d041d0a110f110d1313081c11100600180b000c08140c1e130e0f090c160e0018191e1d1c0016060c11101214121e19070d1a0c1c15020414001f10100c09090600181806001809080e180507021913031100030216141b100908160c1213120f1912011f07021c13190d1900170c1d1203040f071c1908050504130e080d0a100d130b03000a0a08191310090918120f11031104120c15180c15120a0f1919070c1c12060c1911091010120a0d191b040c1613020e1911081f000b1a0b0514150c1613010d0c1c030b17011805090119061e0b051e130c00030419000112030110181d011a000f020c0901080c1113060201041a0e1b060a15160506181c11140c1c1d0b1b14020c131e0b0f071519181e0b1f0e0a08170f1d0c05060e1c1b0e160c0f0a171d0b101a1a1f1417160e0d1414030e161b0a000709100d15020c000e010c00000000 bech32
    genesis1qyfe883hey6jrgj2xvk5g3dfmfqfzm7a4wez4pd2krf7ltsxffd6u6nrvjvv0uzda6whtuhzscj72zuj6udkmknakfn0anc07gaya2303dnngu3sxqctqvg5v7nw0fvkwqce7auqkxv3sj5j7e8d6vu4zy5qlssvffxqccxqcfgwc98zenr3qrzk5msfgkvjnj0ejpl8zunedeqhvajry08ueg99ynwgd2sdntrq22gensffcj03r3yjv4cv4j20ee8vujxve3fssj2demyvknzwe3glqt6t954vknpdvurthpc9fpex7t97nvqryeqpjrpscap6q0zvfpgv3nxzpy6wmx24k9xcu35vuatm5zvn7t084ec7tlw2gh0av9xwumwkv02hats66l5hkwd55rwkm2q8fsd4zvqwpvqqqqtdc6rp

Note: `data` must be converted from 8-bit to 5-bit units.

#### Decode

The `decode` command takes bech32/bech32m string as arguments and outputs `HRP`, `data`, and type.

    $ bech32 decode genesis1qyfe883hey6jrgj2xvk5g3dfmfqfzm7a4wez4pd2krf7ltsxffd6u6nrvjvv0uzda6whtuhzscj72zuj6udkmknakfn0anc07gaya2303dnngu3sxqctqvg5v7nw0fvkwqce7auqkxv3sj5j7e8d6vu4zy5qlssvffxqccxqcfgwc98zenr3qrzk5msfgkvjnj0ejpl8zunedeqhvajry08ueg99ynwgd2sdntrq22gensffcj03r3yjv4cv4j20ee8vujxve3fssj2demyvknzwe3glqt6t954vknpdvurthpc9fpex7t97nvqryeqpjrpscap6q0zvfpgv3nxzpy6wmx24k9xcu35vuatm5zvn7t084ec7tlw2gh0av9xwumwkv02hats66l5hkwd55rwkm2q8fsd4zvqwpvqqqqtdc6rp
    HRP: genesis
    DATA: 000409190707111719041a120308120a060c161408110d091b090009021b1e1d150e190215010d0a1603091e1f0b100609090d1a1c1a13030c120c0c0f1c020d1d1a0e170b1c17021018121e0a021c121a1c0d161b16131d1609130f1d13180f1e081d041d0a110f110d1313081c11100600180b000c08140c1e130e0f090c160e0018191e1d1c0016060c11101214121e19070d1a0c1c15020414001f10100c09090600181806001809080e180507021913031100030216141b100908160c1213120f1912011f07021c13190d1900170c1d1203040f071c1908050504130e080d0a100d130b03000a0a08191310090918120f11031104120c15180c15120a0f1919070c1c12060c1911091010120a0d191b040c1613020e1911081f000b1a0b0514150c1613010d0c1c030b17011805090119061e0b051e130c00030419000112030110181d011a000f020c0901080c1113060201041a0e1b060a15160506181c11140c1c1d0b1b14020c131e0b0f071519181e0b1f0e0a08170f1d0c05060e1c1b0e160c0f0a171d0b101a1a1f1417160e0d1414030e161b0a000709100d15020c000e010c00000000
    TYPE: bech32

If bech32 string has segwit hrp, it will also output witness version and witness program:

    $ bech32 decode bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kt5nd6y
    HRP: bc
    DATA: 010e140f070d1a001912060b0d081504140311021d030c1d03040f1814060e1e160e140f070d1a001912060b0d081504140311021d030c1d03040f1814060e1e16
    TYPE: bech32m
    WITNESS VERSION: 1
    WITNESS PROGRAM: 751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6

If bech32 string has NIP-19 hrp, it will also output NIP-19 entry:

    $ bech32 decode nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p
    HRP: nprofile
    DATA: 00001003171c0606071f051906111114001e17190f090f051d19120f1502011d02011f0f13190a18081c16041d0e0d0a151b1d040b07080101151b17061c191a051c1717040b1318051911161e1b080102151b17061c191a051c1716081a13020c0519121c1c1b010c111516040b13030d1d1610
    TYPE: bech32
    NIP19 Entities:
      special: 3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d
      relay: wss://r.x.com
      relay: wss://djbas.sadkb.com

Note: `DATA` is data without bit conversion. When used, the `DATA` must be converted from 5-bit to 8-bit and padded as necessary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

