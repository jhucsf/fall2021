#! /usr/bin/env ruby

class Fixedprec
  attr_reader :hexstr, :num_frac, :is_neg

  def initialize(hexstr, num_frac = nil)
    is_neg = false
    if hexstr.start_with?('-')
      is_neg = true
      hexstr = hexstr[1..(hexstr.length-1)]
    end

    if m = /^([0-9a-f]+)\.([0-9a-f]+)$/.match(hexstr)
      raise "Don't specify num_frac is hexstr has a decimal point" if !num_frac.nil?
      @hexstr = "#{m[1]}#{m[2]}"
      @num_frac = m[2].length
    elsif m = /^[0-9a-f]+$/.match(hexstr)
      @hexstr = hexstr
      @num_frac = num_frac.nil? ? 0 : num_frac
    else
      raise "Invalid hex string: #{hexstr}"
    end

    @is_neg = is_neg

    #raise "Too many digits in #{hexstr}" if @hexstr.length > 32
    #raise "Too many fraction digits in #{hexstr}" if @num_frac > 16
  end

  def pad(num_frac)
    raise "No" if @num_frac > num_frac

    num_zeroes = num_frac - @num_frac

    hexstr = @is_neg ? '-' : ''
    hexstr += @hexstr
    num_zeroes.times do
      hexstr += '0'
    end

    return Fixedprec.new(hexstr, num_frac)
  end

  def whole_hex
    num_whole = @hexstr.length - @num_frac
    return @hexstr[0..(num_whole-1)]
  end

  def frac_hex
    num_whole = @hexstr.length - @num_frac
    hex = @hexstr[num_whole..-1]
    while hex.length < 16
      hex += '0'
    end
    return hex
  end

  def negate
    s = self.to_s
    if s.start_with?('-')
      return Fixedprec.new(s[1..-1])
    else
      return Fixedprec.new("-#{s}")
    end
  end

  def +(rhs)
    lhs = self

    if lhs.num_frac > rhs.num_frac
      rhs = rhs.pad(lhs.num_frac)
    else
      lhs = lhs.pad(rhs.num_frac)
    end

    raise "wut" if lhs.num_frac != rhs.num_frac

    lhs_int = lhs.hexstr.to_i(16)
    lhs_int *= -1 if lhs.is_neg
    rhs_int = rhs.hexstr.to_i(16)
    rhs_int *= -1 if rhs.is_neg

    sum_int = lhs_int + rhs_int

    return Fixedprec.new(sum_int.to_s(16), lhs.num_frac)
  end

  def -(rhs)
    lhs = self
    return lhs + rhs.negate
  end

  def to_s
    s = @is_neg ? '-' : ''

    num_whole = @hexstr.length - @num_frac
    whole_hex = @hexstr[0..(num_whole-1)]
    frac_hex = @hexstr[num_whole..@hexstr.length-1]

    s += whole_hex
    s += '.'
    s += frac_hex

    return s
  end
end

def randhex
  s = ''
  (rand(15)+1).times do
    s += "0123456789abcdef"[rand(16)]
  end
  return s
end

def mkrand
  sign = (rand(2) == 1) ? '-' : ''
  whole_hex = randhex()
  frac_hex = randhex()
  return Fixedprec.new("#{sign}#{whole_hex}.#{frac_hex}")
end

# options
#  -s    generate a subtraction fact (default is addition)

mode = :add

ARGV.each do |arg|
  case arg
    when '-s'
      mode = :subtraction
    else
      raise "Unknown option: #{arg}"
  end
end

lhs = mkrand
rhs = mkrand

#puts lhs.to_s
#puts rhs.to_s

if mode == :add
  # addition
  sum = lhs + rhs
  puts "#{lhs} + #{rhs} = #{sum}"

elsif mode == :subtraction
  # subtraction
  diff = lhs - rhs
  puts "#{lhs} - #{rhs} = #{diff}"
end
