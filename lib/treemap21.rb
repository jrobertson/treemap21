#!/usr/bin/env ruby

# file: treemap21.rb

require 'rexle'


class Treemap21
  
  attr_reader :to_html

  def initialize(a, orientation: :landscape, debug: false)

    @a, @orientation, @debug = a, orientation, debug
    @to_html = build_html()
    
  end
  
  private

  def build_html()
    
    # used for the box id
    @counter, @count = 2, 1
    
    doc3 = Rexle.new("<div id='box1' class='cbox'/>")
    doc = mapper(doc3, @a, orientation: @orientation)
    boxes = doc.root.xml pretty: true
    
    cbox_css = @a.length.times.with_index.map do |i|
      hex = 3.times.map { rand(60..250).to_s(16) }.join
      "#cbox%s {background-color: #%s}" % [i+1, hex]
    end      

<<EOF
<html>
  <head>
<style>
    .cbox, .long, .cbox1, .cbox1 a {
        width: 100%;
        height: 100%;
    }
    .cbox1 ~.long, .cbox1 {
        float: left;
    }
    .cbox1, .cbox1 a {
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .cbox1 a { 
      text-decoration: none;
      color: #010; 
      font-family: helvetica, arial; 
      color: #115; 
    }
    
    .cbox1 a:hover { background-color: rgba(255,255,255,0.2); color: #902}
    .cbox1 span {  background-color: transparent; color2: #300 }

    .c10 {font-size: 8em}
    .c9 {font-size: 7.5em}
    .c8 {font-size: 6em}
    .c7 {font-size: 5.0em}
    .c6 {font-size: 4.9em}
    .c5 {font-size: 4.5em}
    .c4 {font-size: 3.6em}
    .c3 {font-size: 2.6em}
    .c2 {font-size: 2.4em}
    .c1 {font-size: 1.6em}
    .c0 {font-size: 1.1em}
    
    #{cbox_css.join("\n")}

</style>
  </head>
<body>


#{boxes}

</body>
</html>
EOF
  end

  def add_box(text, url=nil, attr={}, cfont)
    
    span = Rexle::Element.new('span', value: text)
    
    a = attr.map {|key, value| "%s: %s" % [key, value]}
    
    h = {
      id: 'cbox' + @count.to_s,
      class: 'cbox1 ' + cfont, 
      style:  a.join('; ')    
    }
    @count = @count + 1
    
    doc = Rexle::Element.new('div', attributes: h)
    
    if url then
      anchor = Rexle::Element.new('a', attributes: {href: url})
      anchor.root.add span
      doc.root.add anchor.root
    else
      doc.root.add span
      
    end
    
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
    
    # find the largest box
    a2 = a.sort_by {|_, percent, _| percent}
    puts 'a2.first: ' + a2.first.inspect if @debug
    title, percent, url = a2.pop
    
    remainder = total - percent
    # how much space does the largest box take?
    rpct  = 100 / (total / percent.to_f)
    rem_pct  = 100 - rpct

    new_orientation = if rpct.round <= 33 and rpct.round  >= 3 then
      orientation
    else
      orientation == :landscape ? :portrait : :landscape
    end

    puts 'new_orientation: ' + new_orientation.inspect if @debug

    dimension = orientation == :landscape ? :width : :height    
    style = { dimension => rpct.round.to_s + '%'  }
    
    e = add_box(title, url, style, ("c%02d" % percent).to_s[0..-2])
    puts 'e: ' + e.inspect if @debug

    doc.root.add e

    if a2.any? then

      doc3 = Rexle.new("<div id='box%s' class='%s' style='%s: %s%%'/>" % \
                       [@counter, klass, dimension, rem_pct.round.to_s])
      @counter += 1

      doc2 = mapper(doc3, a2, orientation: new_orientation, total: remainder)
      doc.root.add doc2.root

    end

    return doc

  end

end
