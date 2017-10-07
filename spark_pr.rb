# pure ruby sparklines module, generates PNG or ASCII
# contact thomas@fesch.at for questions
#
# strives to be somewhat compatible with sparklines lib by
# {Dan Nugent}[mailto:nugend@gmail.com] and {Geoffrey Grosenbach}[mailto:boss@topfunky.com]
#
# png creation based on http://www.whytheluckystiff.net/bumpspark/

class SparkCanvas
  require 'zlib'

  attr_accessor :color
  attr_reader :width, :height

  # RGBA colors
  WHITE = [0xFF,0xFF,0xFF]
  BLACK = [0x00,0x00,0x00]
  GRAY  = [0x66,0x66,0x66,0xFF]
  RED   = [0xFF,0x00,0x00,0xFF]
  GREEN = [0x00,0x80,0x00,0xFF]

  def initialize(width,height)
    @canvas = []
    @height = height
    @width = width
    height.times{ @canvas << [WHITE]*width }
    @color = BLACK
  end

  # alpha blends two colors, using the alpha given by c2
  def blend(c1, c2)
    (0..2).map{ |i| (c1[i]*(0xFF-c2[3]) + c2[i]*c2[3]) >> 8 }
  end

  # calculate a new alpha given a 0-0xFF intensity
  def intensity(c,i)
    [c[0],c[1],c[2],(c[3]*i) >> 8]
  end

  # calculate perceptive grayscale value
  def grayscale(c)
    (c[0]*0.3 + c[1]*0.59 + c[2]*0.11).to_i
  end

  def point(x,y,color = nil)
    return if x<0 or y<0 or x>@width-1 or y>@height-1
    @canvas[y][x] = blend(@canvas[y][x], color || @color)
  end

  def rectangle(x0, y0, x1, y1)
    x0, y0, x1, y1 = x0.to_i, y0.to_i, x1.to_i, y1.to_i
    x0, x1 = x1, x0 if x0 > x1
    y0, y1 = y1, y0 if y0 > y1
    x0.upto(x1) { |x| y0.upto(y1) { |y| point x, y } }
  end

  # draw an antialiased line
  # google for "wu antialiasing"
  def line(x0, y0, x1, y1)
    # clean params
    x0, y0, x1, y1 = x0.to_i, y0.to_i, x1.to_i, y1.to_i
    y0, y1, x0, x1 = y1, y0, x1, x0 if y0>y1
    sx = (dx = x1-x0) < 0 ? -1 : 1 ; dx *= sx ; dy = y1-y0

    # special cases
    x0.step(x1,sx) { |x| point x, y0 } and return if dy.zero?
    y0.upto(y1)    { |y| point x0, y } and return if dx.zero?
    x0.step(x1,sx) { |x| point x, y0; y0 += 1 } and return if dx==dy

    # main loops
    point x0, y0

    e_acc = 0
    if dy > dx
      e = (dx << 16) / dy
      y0.upto(y1-1) do
        e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xFFFF
        x0 += sx if (e_acc <= e_acc_temp)
        point x0, (y0 += 1), intensity(@color,(w=0xFF-(e_acc >> 8)))
        point x0+sx, y0, intensity(@color,(0xFF-w))
      end
      point x1, y1
      return
    end

    e = (dy << 16) / dx
    x0.step(x1-sx,sx) do
      e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xFFFF
      y0 += 1 if (e_acc <= e_acc_temp)
      point (x0 += sx), y0, intensity(@color,(w=0xFF-(e_acc >> 8)))
      point x0, y0+1, intensity(@color,(0xFF-w))
    end
    point x1, y1
  end

  def polyline(arr)
    (0...arr.size-1).each{ |i| line(arr[i][0], arr[i][1], arr[i+1][0], arr[i+1][1]) }
  end

  def to_png
    header = [137, 80, 78, 71, 13, 10, 26, 10].pack("C*")
    raw_data = @canvas.map { |row| [0] + row }.flatten.pack("C*")
    ihdr_data = [@canvas.first.length,@canvas.length,8,2,0,0,0].pack("NNCCCCC")

    header +
    build_png_chunk("IHDR", ihdr_data) +
    build_png_chunk("tRNS", ([ 0xFF ]*6).pack("C6")) +
    build_png_chunk("IDAT", Zlib::Deflate.deflate(raw_data)) +
    build_png_chunk("IEND", "")
  end

  def build_png_chunk(type,data)
    to_check = type + data
    [data.length].pack("N") + to_check + [Zlib.crc32(to_check)].pack("N")
  end

  def to_ascii
    chr = %w(M O # + ; - .) << ' '
    @canvas.map{ |r| r.map { |pt| chr[grayscale(pt) >> 5] }.to_s << "\n" }.to_s
  end

end

module Spark
  # normalize arr to contain values between 0..1 inclusive
  def Spark.normalize( results, type = :linear )
    hasColorPerValue = results.first.is_a?(Hash)
    values = hasColorPerValue ? results.map { |x| x.keys.first } : results

    values.map! {|v| Math.log(v) } if type == :logarithmic
    adj, fac = values.min, values.max - values.min
    values.map! {|v| (v-adj).quo(fac) rescue 0 }

    if (hasColorPerValue)
      values.each_with_index do |v, i|
        results[i][v] = results[i].delete(results[i].keys.first)
      end
    end

    results
  end

  def Spark.process_options( options )
    o = options.inject({}) do |o, (key, value)|
      o[key.to_sym] = value ; o
    end
    [:height, :width, :step].each do |k|
      o[k] = o[k].to_i if o.has_key?(k)
    end
    [:has_min, :has_max, :has_last].each do |k|
      o[k] = (o[k] ? true : false) if o.has_key?(k)
    end
    o[:normalize] ||= :linear
    o[:normalize] = o[:normalize].to_sym
    o
  end

  def Spark.smooth( results, options = {} )
    options = self.process_options(options)
    o = {
      :step => 2,
      :height => 14,
      :has_min => false,
      :has_max => false
    }.merge(options)

    o[:width] ||= (results.size-1)*o[:step] + 5

    c = SparkCanvas.new(o[:width], o[:height])

    results = Spark.normalize(results, o[:normalize])
    fac = c.height-5
    i = -o[:step]
    coords = results.map do |r|
      [(i += o[:step])+2, c.height - 3 - r*fac ]
    end

    c.color = [0xB0, 0xB0, 0xB0, 0xFF]
    c.polyline coords

    if o[:has_min]
      min_pt = coords[results.index(results.min)]
      c.color = [0x80, 0x80, 0x00, 0x70]
      c.rectangle(min_pt[0]-2, min_pt[1]-2, min_pt[0]+2, min_pt[1]+2)
    end

    if o[:has_max]
      max_pt = coords[results.index(results.max)]
      c.color = [0x00, 0x80, 0x00, 0x70]
      c.rectangle(max_pt[0]-2, max_pt[1]-2, max_pt[0]+2, max_pt[1]+2)
    end

    if o[:has_last]
      c.color = [0xFF, 0x00, 0x00, 0x70]
      c.rectangle(coords.last[0]-2, coords.last[1]-2, coords.last[0]+2, coords.last[1]+2)
    end

    c
  end

  def Spark.discrete( results, options = {} )
    options = self.process_options(options)
    o = {
      :height => 14,
      :threshold => 0.5,
      :has_min => false,
      :has_max => false
    }.merge(options)

    o[:width] ||= results.size*2-1

    canvas = SparkCanvas.new(o[:width], o[:height])

    results = Spark.normalize(results, o[:normalize])
    fac = canvas.height-4

    i = -2
    results.each do |r|
      p = canvas.height - 4 - r*fac
      canvas.color = r < o[:threshold] ? SparkCanvas::GRAY : SparkCanvas::RED
      canvas.line(i+=2, p, i, p+3)
    end

    canvas
  end

  def Spark.bar( results, optionOverrides = {} )
    optionOverrides = self.process_options(optionOverrides)
    options = {
      :height => 14,
      :threshold => 0.5,
      :has_min => false,
      :has_max => false
    }.merge(optionOverrides)

    options[:width] ||= results.size*2 - 1

    canvas = SparkCanvas.new(options[:width], options[:height])

    hasColorPerValue = results.first.is_a?(Hash)
    results = Spark.normalize(results, options[:normalize])
    fac = canvas.height - 4

    bar_height = 10
    bar_left = -2
    bar_spacing = 2

    results.each do |result|
      value = nil
      color = nil

      if (hasColorPerValue)
        value = result.keys.first
        color = result[value]
      else
        value = result
        color = value < options[:threshold] ? SparkCanvas::GRAY : SparkCanvas::RED
      end

      bar_top = canvas.height - 4 - value*fac
      bar_left += bar_spacing

      x0 = bar_left
      y0 = bar_top
      x1 = bar_left
      y1 = canvas.height

      canvas.color = color
      canvas.line(x0, y0, x1, y1)
    end

    canvas
  end

  # convenience method
  def Spark.plot( results, options = {})
    options = self.process_options(options)
    options[:type] ||= 'smooth'
    self.send(options[:type], results, options).to_png
  end
end

#to test this:
#PNG output
#File.open( 'test.png', 'wb' ) do |png|
#  png << Spark.plot( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, 'has_last' => 'true', 'height' => '40', :step => 10, :normalize => 'logarithmic' )
#end

#ASCII output
#puts Spark.discrete( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 1, 98, 34, 53, 97, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, :height => 14, :step => 5 ).to_ascii
#puts Spark.smooth( [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 1, 98, 34, 53, 97, 55, 74, 63, 38, 31, 98, 89], :has_min => true, :has_max => true, :height => 14, :step => 4 ).to_ascii
