#!/usr/bin/env ruby

# file: treemap21.rb


require 'rexle'


class Treemap21

  def initialize(a, orientation: :landscape, debug: false)

    @a, @orientation, @debug = a, orientation, debug

  end

  def to_html()

    doc3 = Rexle.new("<div class='cbox'/>")
    doc = mapper(doc3, @a, orientation: @orientation)
    boxes = doc.root.xml pretty: true

<<EOF
<html>
  <head>
<style>

    .cbox, .long, .cbox1 {
        width: 100%;
        height: 100%;
    }
    .cbox1 ~.long, .cbox1 {
        float: left;
    }
    .cbox1 {
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .cbox1 span {  background-color: transparent;}

    .c10 {font-size: 8em}
    .c9 {font-size: 7.5em}
    .c8 {font-size: 6em}
    .c7 {font-size: 5.0em}
    .c6 {font-size: 4.9em}
    .c5 {font-size: 4.5em}
    .c4 {font-size: 3.2em}
    .c3 {font-size: 2.1em}
    .c2 {font-size: 1.9em}
    .c1 {font-size: 1.6em}
    .c0 {font-size: 1.1em}

</style>
  </head>
<body>


#{boxes}

</body>
</html>
EOF
  end

  private

  def add_box(text, attr={}, cfont)

    a = attr.map {|key, value| "%s: %s" % [key, value]}
    h = {class: 'cbox1 ' + cfont, style:  a.join('; ')}
    span = Rexle::Element.new('span', value: text)
    doc = Rexle::Element.new('div', attributes: h)
    doc.root.add span
    doc.root

  end

  def mapper(doc, a, orientation: :landscape, total: 100)

    if @debug then
      puts 'orientation: ' + orientation.inspect 
      puts 'total: ' + total.inspect
    end

    klass = if orientation == :landscape then
      @canvas_width = 100; @canvas_height = @canvas_width / 2
      'long'
    else
      @canvas_height = 100; @canvas_width = @canvas_height / 2
      'cbox'
    end

    bgcolor = 3.times.map { rand(60..250).to_s(16) }.join
    
    # find the largest box
    a2 = a.sort_by(&:last).reverse
    puts 'a2.first: ' + a2.first.inspect if @debug
    title, percent = a2.first
    
    remainder = total - percent
    # how much space does the largest box take?
    rem  = 100 / (total / percent.to_f)
    rem2  = 100 - rem

    new_orientation = if rem <= 30 then
      orientation
    else
      orientation == :landscape ? :portrait : :landscape
    end

    puts 'new_orientation: ' + new_orientation.inspect if @debug

    dimension = orientation == :landscape ? :width : :height
    
    style = {
      :"background-color" => '#' + bgcolor, 
      dimension => rem.round.to_s + '%'
    }
    
    e = add_box(title, style, ("c%02d" % percent).to_s[0..-2])
    puts 'e: ' + e.inspect if @debug

    doc.root.add e

    if a2.length > 1 then

      dim2 = orientation == :landscape ? 'width' : 'height'
      doc3 = Rexle.new("<div class='%s' style='%s: %s%%'/>" % [klass, dim2, 
        rem2.round.to_s])

      doc2 = mapper(doc3, a2[1..-1], orientation: new_orientation, total: remainder)

      doc.root.add doc2.root

    end

    return doc

  end

end
