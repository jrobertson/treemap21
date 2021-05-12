#!/usr/bin/env ruby

# file: treemap21.rb

require 'rexle'
require 'polyrex'


class Treemap21
  
  attr_reader :to_html

  def initialize(obj, orientation: :landscape, debug: false)

    @orientation, @debug = orientation, debug
        
    @a = case obj
    when Array
      a
    when String

      if obj.lstrip =~ /<?polyrex / then
        
        px = Polyrex.new obj                
        doc = Rexle.new(px.to_tree)
        scan_xml(doc.root)        
      
      elsif obj.lstrip =~ /</ then
        
        doc = Rexle.new(obj)
        scan_xml(doc.root)        
        
      else
        
        # most likely a raw polyrex document without the processing 
        # instruction or header
        
        head =  "<?polyrex schema='items[title, description]/item[title," +
            " pct, url]' delimiter=' # '?>\ntitle: Unititled\ndescription: " + 
            "Treemap record data"

        s = head + "\n\n" + obj.lstrip
        px = Polyrex.new s
        doc = Rexle.new(px.to_tree)
        scan_xml(doc.root)        
        
      end
      
    end

    @to_html = build_html()
    
  end
  
  private

  def build_html()
    
    # used for the box id
    @counter, @count = 2, 1
    
    doc3 = Rexle.new("<div id='box1' class='cbox'/>")
    doc = mapper(doc3, @a, orientation: @orientation)
    
    cbox_css = doc.root.xpath('//div[@class="cbox1"]').map do |e|
      hex = 3.times.map { rand(60..250).to_s(16) }.join      
      "#%s { background-color: #%s}" % [e.attributes[:id], hex]
    end
    
    boxes = doc.root.xml pretty: true
    

<<EOF
<html>
  <head>
<style>
    .cbox, .long, .cbox1, .cbox1 a {
        width: 100%;
        height: 100%;
    }
    .long, .cbox1 {
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
    
    .cbox {position: relative}

    .glabel {
      background-color: #111;
      width: 100%;
      height: 30px;
      color: #fff; font-size: 1.6vw;
      position: absolute;
      z-index: 1
    }

    .gfoot {
      background-color: #111;
      width: 100%;
      height: 20px;
      position: absolute;
      bottom: 0;
     }

    .group {      border: 0px solid black;}    

    .c10 {font-size: 8vw}
    .c9 {font-size: 7.5vw}
    .c8 {font-size: 6vw}
    .c7 {font-size: 5.0vw}
    .c6 {font-size: 4.9vw}
    .c5 {font-size: 4.5vw}
    .c4 {font-size: 3.6vw}
    .c3 {font-size: 2.6vw}
    .c2 {font-size: 2.4vw}
    .c1 {font-size: 1.6vw}
    .c0 {font-size: 1.1vw}
    
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
    
    #a = attr.map {|key, value| "%s: %s" % [key, value]}
    
    h = {
      id: 'cbox' + @count.to_s,
      class: 'cbox1 ' + cfont
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

  def mapper(doc, a, orientation: :landscape, total: 100, scale: 100)
    
    if @debug then
      puts 'a: ' + a.inspect
      puts 'orientation: ' + orientation.inspect 
      puts 'total: ' + total.inspect
      puts 'scale: ' + scale.inspect
    end

    klass = if orientation == :landscape then
      @canvas_width = 100; @canvas_height = @canvas_width / 2
      'long'
    else
      @canvas_height = 100; @canvas_width = @canvas_height / 2
      'cbox'
    end
    
    a.map! do |x|
      x[1] = x[1].nil? ? 1 : x[1].to_f
      x
    end
    
    # find the largest box
    a2 = a.sort_by {|_, val, _| val}
    
    # get the total value
    total = a2.sum {|x| x[1]}
    puts 'total ; ' + total.inspect if @debug

    
    # calculate the percentages
    a3 = a2.map do |title, val, url, list|
      apct = 100 / (total / val.to_f)
      [title, val, url, list, apct]
    end
    puts 'a3: ' + a3.inspect if @debug
    
    puts 'a3.first: ' + a3.first.inspect if @debug
    item = a3.pop

    percent = item[1]
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
    
    h = {
      class: klass,
      style: style.map {|key, value| "%s: %s" % [key, value]}.join(';')
    }
    
    div = Rexle::Element.new('div', attributes: h)      
    
    
    if item[3].is_a? Array then
      
      # it's a group item
      group_name, url = item.values_at(0, 2)
      #<div class='glabel'>  <span>Group A</span>      </div>      
      group = Rexle::Element.new('div', attributes: {class: 'glabel'})      
      span = Rexle::Element.new('span', value: group_name)
      
      if url then
        
        anchor = Rexle::Element.new('a', attributes: {href: url})
        anchor.root.add span
        group.add anchor.root
        
      else
        
        group.add span
        
      end
            
      div.add group
      
      doc4 = Rexle.new("<div id='box%s' class='%s' style='%s: %s%%'/>" % \
                       [@counter, klass, dimension, rem_pct.round.to_s])            
      
      mapper(div, item[3], orientation: orientation, scale: scale)

      group_foot = Rexle::Element.new('div', attributes: {class: 'gfoot'})
      div.add group_foot      
      
    else
      
      title, value, url, list, percent = item

      factor = scale / (100 / percent.to_f)
      
      if @debug then
        puts 'scale: ' + scale.inspect
        puts 'percent: ' + percent.inspect
        puts 'factor: ' + factor.inspect
      end
      
      e = add_box(title, url, {}, ("c%02d" % factor).to_s[0..-2])
      puts 'e: ' + e.inspect if @debug
            
    end        
    
    div.add e
    doc.root.add div

    if a3.any? then

      doc3 = Rexle.new("<div id='box%s' class='%s' style='%s: %s%%'/>" % \
                       [@counter, klass, dimension, rem_pct.round.to_s])
      @counter += 1

      doc2 = mapper(doc3, a3, orientation: new_orientation, total: remainder, 
                    scale: rem_pct.round)
      doc.root.add doc2.root

    end    
    
    return doc

  end
  
  def scan_xml(e)

    e.xpath('item').map do |node|

      title, pct, url = node.attributes.values

      r = [title, pct, url]
      r << scan_xml(node) if node.children.any?
      r
    end

  end

end
