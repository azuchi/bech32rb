require 'spec_helper'

RSpec.describe Bech32::Nostr::NIP19 do
  describe 'decode and encode' do
    it do
      # public key
      bech32 = 'npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qzvjptg'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_PUBKEY)
      expect(entity.data).to eq('7e7e9c42a91bfef19fa929e5fda1b72e0ebc1a4c1141673e2794234d86addf4e')
      expect(entity.encode).to eq(bech32)

      # private key
      bech32 = 'nsec1vl029mgpspedva04g90vltkh6fvh240zqtv9k0t9af8935ke9laqsnlfe5'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_PRIVATE_KEY)
      expect(entity.data).to eq('67dea2ed018072d675f5415ecfaed7d2597555e202d85b3d65ea4e58d2d92ffa')
      expect(entity.encode).to eq(bech32)

      # profile
      bech32 = 'nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gpp4mhxue69uhhytnc9e3k7mgpz4mhxue69uhkg6nzv9ejuumpv34kytnrdaksjlyr9p'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_PROFILE)
      expect(entity.entries.length).to eq(3)
      expect(entity.entries[0].type).to eq(Bech32::Nostr::TLVEntity::TYPE_SPECIAL)
      expect(entity.entries[0].label).to eq('pubkey')
      expect(entity.entries[0].value).to eq('3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d')
      expect(entity.entries[1].type).to eq(Bech32::Nostr::TLVEntity::TYPE_RELAY)
      expect(entity.entries[1].label).to eq('relay')
      expect(entity.entries[1].value).to eq('wss://r.x.com')
      expect(entity.entries[2].type).to eq(Bech32::Nostr::TLVEntity::TYPE_RELAY)
      expect(entity.entries[2].label).to eq('relay')
      expect(entity.entries[2].value).to eq('wss://djbas.sadkb.com')
      expect(entity.encode).to eq(bech32)

      # naddr
      bech32 = 'naddr1qq98yetxv4ex2mnrv4esygrl54h466tz4v0re4pyuavvxqptsejl0vxcmnhfl60z3rth2xkpjspsgqqqw4rsf34vl5'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE)
      expect(entity.entries.length).to eq(3)
      expect(entity.entries[0].type).to eq(Bech32::Nostr::TLVEntity::TYPE_SPECIAL)
      expect(entity.entries[0].label).to eq('identifier')
      expect(entity.entries[0].value).to eq('references')
      expect(entity.entries[1].type).to eq(Bech32::Nostr::TLVEntity::TYPE_AUTHOR)
      expect(entity.entries[1].label).to eq('author')
      expect(entity.entries[1].value).to eq('7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194')
      expect(entity.entries[2].type).to eq(Bech32::Nostr::TLVEntity::TYPE_KIND)
      expect(entity.entries[2].label).to eq('kind')
      expect(entity.entries[2].value).to eq(30023)
      expect(entity.encode).to eq(bech32)

      bech32 = 'naddr1qqrxyctwv9hxzq3q80cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsxpqqqp65wqfwwaehxw309aex2mrp0yhxummnw3ezuetcv9khqmr99ekhjer0d4skjm3wv4uxzmtsd3jjucm0d5q3vamnwvaz7tmwdaehgu3wvfskuctwvyhxxmmd0zfmwx'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE)
      expect(entity.entries.length).to eq(5)
      expect(entity.entries[0].type).to eq(Bech32::Nostr::TLVEntity::TYPE_SPECIAL)
      expect(entity.entries[0].label).to eq('identifier')
      expect(entity.entries[0].value).to eq('banana')
      expect(entity.entries[1].type).to eq(Bech32::Nostr::TLVEntity::TYPE_AUTHOR)
      expect(entity.entries[1].label).to eq('author')
      expect(entity.entries[1].value).to eq('3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d')
      expect(entity.entries[2].type).to eq(Bech32::Nostr::TLVEntity::TYPE_KIND)
      expect(entity.entries[2].label).to eq('kind')
      expect(entity.entries[2].value).to eq(30023)
      expect(entity.entries[3].type).to eq(Bech32::Nostr::TLVEntity::TYPE_RELAY)
      expect(entity.entries[3].label).to eq('relay')
      expect(entity.entries[3].value).to eq('wss://relay.nostr.example.mydomain.example.com')
      expect(entity.entries[4].type).to eq(Bech32::Nostr::TLVEntity::TYPE_RELAY)
      expect(entity.entries[4].label).to eq('relay')
      expect(entity.entries[4].value).to eq('wss://nostr.banana.com')
      expect(entity.encode).to eq(bech32)

      # nevent
      bech32 = 'nevent1qqs860kwt3m500hfnve6vxdpagkfqkm6hq03dnn2n7u8dev580kd2uszyztuwzjyxe4x2dwpgken87tna2rdlhpd02va5cvvgrrywpddnr3jydc2w4t'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_EVENT)
      expect(entity.entries.length).to eq(2)
      expect(entity.entries[0].type).to eq(Bech32::Nostr::TLVEntity::TYPE_SPECIAL)
      expect(entity.entries[0].label).to eq('id')
      expect(entity.entries[0].value).to eq('7d3ece5c7747bee99b33a619a1ea2c905b7ab81f16ce6a9fb876e5943becd572')
      expect(entity.entries[1].type).to eq(Bech32::Nostr::TLVEntity::TYPE_AUTHOR)
      expect(entity.entries[1].label).to eq('author')
      expect(entity.entries[1].value).to eq('97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322')
      expect(entity.encode).to eq(bech32)

      # nrelay
      bech32 = 'nrelay1qqvhwumn8ghj7un9d3shjtnwdaehgu3wv4uxzmtsd3jsh6r089'
      entity = described_class.decode(bech32)
      expect(entity.hrp).to eq(Bech32::Nostr::NIP19::HRP_RELAY)
      expect(entity.entries.length).to eq(1)
      expect(entity.entries[0].type).to eq(Bech32::Nostr::TLVEntity::TYPE_SPECIAL)
      expect(entity.entries[0].label).to eq('relay')
      expect(entity.entries[0].value).to eq('wss://relay.nostr.example')
      expect(entity.encode).to eq(bech32)
    end

    context 'invalid nip19 string' do
      it do
        # invalid hrp
        expect { described_class.decode('npuc10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qa8zykk') }.
          to raise_error(ArgumentError, 'HRP npuc is unsupported.')
        # Invalid public key(33 bytes)
        expect { described_class.decode('npub1qdl8a8zz4ydlauvl4y57tldpkuhqa0q6fsg5zee7y72zxnvx4h05uk8223u') }.
          to raise_error(ArgumentError, 'Data whose HRP is npub must be 32 bytes.')
        # Bech32m
        expect { described_class.decode('npub10elfcs4fr0l0r8af98jlmgdh9c8tcxjvz9qkw038js35mp4dma8qhszdw2') }.
          to raise_error(ArgumentError, 'Invalid bech32 spec.')
      end
    end

    context 'string values' do
      let(:author) { '7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194' }

      it 'returns relay and identifier as UTF-8 strings' do
        bech32 = 'naddr1qqrxyctwv9hxzq3q80cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsxpqqqp65wqfwwaehxw309aex2mrp0yhxummnw3ezuetcv9khqmr99ekhjer0d4skjm3wv4uxzmtsd3jjucm0d5q3vamnwvaz7tmwdaehgu3wvfskuctwvyhxxmmd0zfmwx'
        entity = described_class.decode(bech32)
        expect(entity.entries[0].value.encoding).to eq(Encoding::UTF_8)
        expect(entity.entries[3].value.encoding).to eq(Encoding::UTF_8)

        bech32 = 'nrelay1qqvhwumn8ghj7un9d3shjtnwdaehgu3wv4uxzmtsd3jsh6r089'
        expect(described_class.decode(bech32).entries[0].value.encoding).to eq(Encoding::UTF_8)
      end

      it 'round-trips a non-ASCII identifier' do
        identifier = 'バナナ'
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, identifier),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, author),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_KIND, 30023)
        ]
        bech32 = Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE, entries).encode
        entity = described_class.decode(bech32)
        expect(entity.entries[0].value).to eq(identifier)
        expect(entity.entries[0].value.encoding).to eq(Encoding::UTF_8)
        expect(entity.encode).to eq(bech32)
      end
    end

    context 'special entry with unsupported hrp' do
      it do
        data = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 1].pack('CC') + 'x'
        expect { Bech32::Nostr::TLVEntity.parse('npub', data) }.
          to raise_error(ArgumentError, 'HRP npub is unsupported.')
      end
    end

    context 'unrecognized or unsupported tlv' do
      let(:pubkey) { '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d' }

      it 'ignores an unknown tlv type' do
        # nprofile with a pubkey and an entry of type 9 ("abc")
        entity = described_class.decode('nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gfqdskyccva3qfy')
        expect(entity.entries.map(&:type)).to eq([Bech32::Nostr::TLVEntity::TYPE_SPECIAL])
        expect(entity.entries[0].value).to eq(pubkey)
      end

      it 'ignores an empty unknown tlv' do
        # nevent with an id and an empty entry of type 9
        entity = described_class.decode('nevent1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gfqq0tksds')
        expect(entity.entries.map(&:value)).to eq([pubkey])
      end

      it 'ignores a tlv type the hrp does not support' do
        # nprofile with a pubkey and an author (type 2) entry
        entity = described_class.decode('nprofile1qqsrhuxx8l9ex335q7he0f09aej04zpazpl0ne2cgukyawd24mayt8gzyqalp33lewf5vdq847t6te0wvnags0gs0mu72kz8938tn24wlfze69gy888')
        expect(entity.entries.map(&:type)).to eq([Bech32::Nostr::TLVEntity::TYPE_SPECIAL])
      end
    end

    context 'missing required tlv' do
      let(:special) { [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 32].pack('CC') + ("\x01" * 32).b }
      let(:unknown) { [9, 3].pack('CC') + 'abc' }

      it 'rejects an entity that has only unknown tlvs' do
        %w[nprofile nevent nrelay naddr].each do |hrp|
          expect { Bech32::Nostr::TLVEntity.parse(hrp, unknown) }.
            to raise_error(ArgumentError, "Invalid TLV: missing required type 0 for HRP: #{hrp}")
        end
      end

      it 'rejects an naddr without author or kind' do
        author = [Bech32::Nostr::TLVEntity::TYPE_AUTHOR, 32].pack('CC') + ("\x02" * 32).b
        kind = [Bech32::Nostr::TLVEntity::TYPE_KIND, 4].pack('CC') + [30023].pack('N')
        expect { Bech32::Nostr::TLVEntity.parse('naddr', special + kind) }.
          to raise_error(ArgumentError, 'Invalid TLV: missing required type 2 for HRP: naddr')
        expect { Bech32::Nostr::TLVEntity.parse('naddr', special + author) }.
          to raise_error(ArgumentError, 'Invalid TLV: missing required type 3 for HRP: naddr')
        entity = Bech32::Nostr::TLVEntity.parse('naddr', special + unknown + author + kind)
        expect(entity.entries.map(&:type)).to eq([0, 2, 3])
      end
    end

    context 'tlv value length' do
      it 'rejects a pubkey, id or author that is not 32 bytes when parsing' do
        [0, 1, 31, 33].each do |len|
          special = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, len].pack('CC') + ("\x01" * len).b
          %w[nprofile nevent].each do |hrp|
            expect { Bech32::Nostr::TLVEntity.parse(hrp, special) }.
              to raise_error(ArgumentError, "Invalid TLV: type 0 for HRP: #{hrp} must be 32 bytes.")
          end
          id = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 32].pack('CC') + ("\x01" * 32).b
          author = [Bech32::Nostr::TLVEntity::TYPE_AUTHOR, len].pack('CC') + ("\x02" * len).b
          expect { Bech32::Nostr::TLVEntity.parse('nevent', id + author) }.
            to raise_error(ArgumentError, 'Invalid TLV: type 2 for HRP: nevent must be 32 bytes.')
        end
      end

      it 'rejects a 1-byte event id when decoding' do
        bech32 = Bech32.encode('nevent', Bech32.convert_bits([0, 1, 0xab], 8, 5), Bech32::Encoding::BECH32)
        expect { described_class.decode(bech32) }.
          to raise_error(ArgumentError, 'Invalid TLV: type 0 for HRP: nevent must be 32 bytes.')
      end

      it 'rejects an empty nrelay relay but accepts an empty naddr identifier' do
        expect { Bech32::Nostr::TLVEntity.parse('nrelay', [0, 0].pack('CC')) }.
          to raise_error(ArgumentError, 'Invalid TLV: type 0 for HRP: nrelay must not be empty.')
        author = [Bech32::Nostr::TLVEntity::TYPE_AUTHOR, 32].pack('CC') + ("\x02" * 32).b
        kind = [Bech32::Nostr::TLVEntity::TYPE_KIND, 4].pack('CC') + [30023].pack('N')
        entity = Bech32::Nostr::TLVEntity.parse('naddr', [0, 0].pack('CC') + author + kind)
        expect(entity.entries[0].value).to eq('')
      end

      it 'rejects a pubkey, id or author that is not 32 bytes when encoding' do
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 'ab')]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: type 0 for HRP: nevent must be 32 bytes.')
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 'ab' * 32),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, 'cd' * 31)
        ]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: type 2 for HRP: nevent must be 32 bytes.')
      end
    end

    context 'encoding validation' do
      let(:pubkey) { '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d' }

      it 'rejects an entity without the required types' do
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 'x')]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: missing required type 2 for HRP: naddr')
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_RELAY, 'wss://relay.example')]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: missing required type 0 for HRP: nevent')
      end

      it 'rejects a type the hrp does not support' do
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, pubkey),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, pubkey)
        ]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_PROFILE, entries).encode }.
          to raise_error(ArgumentError, 'Type 2 is unsupported for HRP: nprofile')
      end
    end

    context 'bare entity data' do
      it 'rejects data that is not a hex string' do
        ['z' * 64, '0' * 63 + 'g', nil].each do |data|
          expect { Bech32::Nostr::BareEntity.new('npub', data) }.
            to raise_error(ArgumentError, 'Data must be a hex string.')
        end
      end
    end

    context 'tlv entry value type' do
      it 'requires an Integer kind' do
        expect { Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_KIND, '1') }.
          to raise_error(ArgumentError, 'Value of kind must be Integer. String given.')
      end

      it 'requires a String value for other types' do
        [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, Bech32::Nostr::TLVEntity::TYPE_RELAY,
         Bech32::Nostr::TLVEntity::TYPE_AUTHOR].each do |type|
          expect { Bech32::Nostr::TLVEntry.new(type, 1) }.
            to raise_error(ArgumentError, "Value of type #{type} must be String. Integer given.")
        end
      end
    end

    context 'tlv string encoding' do
      let(:pubkey) { '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d' }
      let(:special) { [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 32].pack('CC') + ("\x01" * 32).b }
      let(:author) { [Bech32::Nostr::TLVEntity::TYPE_AUTHOR, 32].pack('CC') + ("\x02" * 32).b }
      let(:kind) { [Bech32::Nostr::TLVEntity::TYPE_KIND, 4].pack('CC') + [30023].pack('N') }

      it 'rejects a non-ASCII relay when parsing' do
        relay = [Bech32::Nostr::TLVEntity::TYPE_RELAY, 2].pack('CC') + "\xff\xfe".b
        expect { Bech32::Nostr::TLVEntity.parse('nprofile', special + relay) }.
          to raise_error(ArgumentError, 'Invalid TLV: relay must be ASCII.')
        nrelay = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 3].pack('CC') + 'é'.b + 'x'
        expect { Bech32::Nostr::TLVEntity.parse('nrelay', nrelay) }.
          to raise_error(ArgumentError, 'Invalid TLV: relay must be ASCII.')
      end

      it 'rejects an identifier that is not valid UTF-8 when parsing' do
        identifier = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 2].pack('CC') + "\xff\xfe".b
        expect { Bech32::Nostr::TLVEntity.parse('naddr', identifier + author + kind) }.
          to raise_error(ArgumentError, 'Invalid TLV: identifier must be valid UTF-8.')
      end

      it 'rejects a non-ASCII relay or an invalid identifier when encoding' do
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, pubkey),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_RELAY, 'wss://リレー.example')
        ]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_PROFILE, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: relay must be ASCII.')
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, "\xff".b),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, pubkey),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_KIND, 30023)
        ]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE, entries).encode }.
          to raise_error(ArgumentError, 'Invalid TLV: identifier must be valid UTF-8.')
      end
    end

    context 'tlv value encoding' do
      let(:author) { '7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194' }

      it 'round-trips a hex-like naddr identifier as a raw string' do
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 'beef'),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, author),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_KIND, 30023)
        ]
        bech32 = Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT_COORDINATE, entries).encode
        entity = described_class.decode(bech32)
        expect(entity.entries[0].value).to eq('beef')
        expect(entity.entries[1].value).to eq(author)
        expect(entity.entries[2].value).to eq(30023)
        expect(entity.encode).to eq(bech32)
      end

      it 'round-trips a hex-like nrelay value as a raw string' do
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, '1234')]
        bech32 = Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_RELAY, entries).encode
        entity = described_class.decode(bech32)
        expect(entity.entries[0].value).to eq('1234')
        expect(entity.encode).to eq(bech32)
      end

      it 'rejects a non-hex value for a hex-typed entry' do
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 'not hex')]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_PROFILE, entries).encode }.
          to raise_error(ArgumentError, 'Value of type 0 must be a hex string.')
        entries = [Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_AUTHOR, 'not hex')]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, entries).encode }.
          to raise_error(ArgumentError, 'Value of type 2 must be a hex string.')
      end

      it 'rejects a value longer than 255 bytes' do
        relay = 'wss://' + 'r' * 250
        entries = [
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, author),
          Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_RELAY, relay)
        ]
        expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_PROFILE, entries).encode }.
          to raise_error(ArgumentError, 'Value must be at most 255 bytes.')

        # exactly 255 bytes is allowed
        relay = 'wss://' + 'r' * 249
        entries[1] = Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_RELAY, relay)
        bech32 = Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_PROFILE, entries).encode
        entity = described_class.decode(bech32)
        expect(entity.entries[1].value).to eq(relay)
        expect(entity.encode).to eq(bech32)
      end

      it 'rejects a kind out of 32-bit range' do
        [-1, 2**32].each do |kind|
          entries = [
            Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_SPECIAL, author),
            Bech32::Nostr::TLVEntry.new(Bech32::Nostr::TLVEntity::TYPE_KIND, kind)
          ]
          expect { Bech32::Nostr::TLVEntity.new(Bech32::Nostr::NIP19::HRP_EVENT, entries).encode }.
            to raise_error(ArgumentError, 'Integer value must be between 0 and 4294967295.')
        end
      end

      it 'rejects a kind whose length is not 4 bytes when parsing' do
        id = [Bech32::Nostr::TLVEntity::TYPE_SPECIAL, 32].pack('CC') + ("\x01" * 32).b
        [0, 1, 3, 5].each do |len|
          data = id + [Bech32::Nostr::TLVEntity::TYPE_KIND, len].pack('CC') + ("\x00" * len).b
          expect { Bech32::Nostr::TLVEntity.parse(Bech32::Nostr::NIP19::HRP_EVENT, data) }.
            to raise_error(ArgumentError, 'Invalid TLV: kind must be 4 bytes.')
        end
        data = id + [Bech32::Nostr::TLVEntity::TYPE_KIND, 4].pack('CC') + [30023].pack('N')
        entity = Bech32::Nostr::TLVEntity.parse(Bech32::Nostr::NIP19::HRP_EVENT, data)
        expect(entity.entries[1].value).to eq(30023)
      end
    end
  end
end
