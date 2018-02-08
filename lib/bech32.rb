module Bech32

  autoload :SegwitAddr, 'bech32/segwit_addr'

  SEPARATOR = '1'

  CHARSET = %w(q p z r y 9 x 8 g f 2 t v d w 0 s 3 j n 5 4 k h c e 6 m u a 7 l)

  module_function

  # Returns the encoded Bech32 string.
  #
  #   require 'bech32'
  #
  #   bech = Bech32.encode('bc', [])
  #
  #   <i>Generates:</i>
  #   'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4' # bech
  #
  def encode(hrp, data)
    checksummed = data + create_checksum(hrp, data)
    hrp + SEPARATOR + checksummed.map{|i|CHARSET[i]}.join
  end

  # Returns the Bach32 decoded hrp and data.
  #
  #   require 'bech32'
  #
  #   addr = 'BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4'
  #   hrp, data = Bech32.decode(addr)
  #
  #   <i>Generates:</i>
  #   'bc' # hrp
  #   [0, 14, 20, 15, 7, 13, 26, 0, 25, 18, 6, 11, 13, 8, 21, 4, 20, 3, 17, 2, 29, 3, 12, 29, 3, 4, 15, 24, 20, 6, 14, 30, 22] # data
  #
  def decode(bech)
    # check invalid bytes
    return nil if bech.scrub('?').include?('?')
    # check uppercase/lowercase
    return nil if (bech.downcase != bech && bech.upcase != bech)
    bech.each_char{|c|return nil if c.ord < 33 || c.ord > 126}
    bech = bech.downcase
    # check data length
    pos = bech.rindex(SEPARATOR)
    return nil if pos.nil? || pos + 7 > bech.length #|| bech.length > 90
    # check valid charset
    bech[pos+1..-1].each_char{|c|return nil unless CHARSET.include?(c)}
    # split hrp and data
    hrp = bech[0..pos-1]
    data = bech[pos+1..-1].each_char.map{|c|CHARSET.index(c)}
    # check checksum
    return nil unless verify_checksum(hrp, data)
    [hrp, data[0..-7]]
  end

  # Returns computed checksum values of +hrp+ and +data+
  def create_checksum(hrp, data)
    values = expand_hrp(hrp) + data
    polymod = polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
    (0..5).map{|i|(polymod >> 5 * (5 - i)) & 31}
  end

  # Verify a checksum given Bech32 string
  def verify_checksum(hrp, data)
    polymod(expand_hrp(hrp) + data) == 1
  end

  # Expand the hrp into values for checksum computation.
  def expand_hrp(hrp)
    hrp.each_char.map{|c|c.ord >> 5} + [0] + hrp.each_char.map{|c|c.ord & 31}
  end

  # Compute Bech32 checksum
  def polymod(values)
    generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    chk = 1
    values.each do |v|
      top = chk >> 25
      chk = (chk & 0x1ffffff) << 5 ^ v
      (0..4).each{|i|chk ^= ((top >> i) & 1) == 0 ? 0 : generator[i]}
    end
    chk
  end

  private_class_method :polymod, :expand_hrp

end
