#!/usr/bin/env ruby

# file: treemap21.rb

require 'c32'
require 'rexle'
require 'weblet'
require 'polyrex'


class Treemap21
  using ColouredText
  
  attr_reader :to_html, :title

  def initialize(obj, orientation: :landscape, title: 'Treemap', 
                 weblet_file: nil, debug: false)

    @orientation, @title, @debug = orientation, title, debug
        
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

    weblet_file ||= File.join(File.dirname(__FILE__), '..', 'data',
                              'treemap21.txt')      
    @to_html = build_html(weblet_file)
    
  end
  
  private

  def build_html(weblet_file)
    
    # used for the box id
    @counter, @count = 2, 1
    
    doc3 = Rexle.new("<div id='box1' class='cbox'/>")
    doc = mapper(doc3, @a, orientation: @orientation)
    
    cbox_css = doc.root.xpath('//div[@class="cbox1"]').map do |e|
      hex = 3.times.map { rand(60..250).to_s(16) }.join      
      "#%s { background-color: #%s}" % [e.attributes[:id], hex]
    end
    
    boxes = doc.root.xml pretty: true
    w = Weblet.new(weblet_file)

    w.render :html, binding
    
  end

  def add_box(text, url=nil, attr={})
    
    span = Rexle::Element.new('span', value: text)
    
    #a = attr.map {|key, value| "%s: %s" % [key, value]}
    
    h = {
      id: 'cbox' + @count.to_s,
      class: 'cbox1 '
    }
    @count = @count + 1
    
    doc = Rexle::Element.new('div', attributes: h)
    
    if url then
      anchor = Rexle::Element.new('a', attributes: {href: url, draggable: 'false'})
      anchor.root.add span
      doc.root.add anchor.root
    else
      doc.root.add span
      
    end
    
    doc.root
    
  end

  def mapper(doc, a, orientation: :landscape, total: 100)
    
    if @debug then
      puts 'a: ' + a.inspect
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

    new_orientation = if rpct.round <= 133 and rpct.round  >= 9993 then
      orientation
    else
      orientation == :landscape ? :portrait : :landscape
    end

    puts 'new_orientation: ' + new_orientation.inspect if @debug
    
    dimension = orientation == :landscape ? :width : :height    
    hstyle = { dimension => rpct.round.to_s + '%'  }
    style = hstyle.map {|key, value| "%s: %s" % [key, value]}.join(';')
    
    h = {
      class: klass,
      style: style
    }
    
    div = Rexle::Element.new('div', attributes: h)      
    
    
    if item[3].is_a? Array then
      
      # it's a group item
      group_name, url = item.values_at(0, 2)
      #<div class='glabel'>  <span>Group A</span>      </div>      
      group = Rexle::Element.new('div', attributes: {style: style, class: 'glabel'})      
      span = Rexle::Element.new('span', value: group_name)
      
      if url then
        
        anchor = Rexle::Element.new('a', attributes: {href: url})
        anchor.root.add span
        group.add anchor.root
        
      else
        
        group.add span
        
      end
            
      div.add group

      style = "%s: %s%%; font-size: %s%%" % [ dimension, rem_pct.round, 
                                            rem_pct.round]      
      doc4 = Rexle.new("<div id='box%s' class='%s' style='%s'/>" % \
                       [@counter, klass, style])            
      puts ('rem_pct: ' + rem_pct.inspect).debug if @debug
      mapper(div, item[3], orientation: orientation)

      #group_foot = Rexle::Element.new('div', attributes: {class: 'gfoot'})
      #div.add group_foot      
      
    else
      
      title, value, url, list, percent = item

      
      if @debug then
        puts 'percent: ' + percent.inspect
      end
      
      #e = add_box(title, url, {}, ("c%02d" % factor).to_s[0..-2])
      e = add_box(title, url, {})
      puts 'e: ' + e.inspect if @debug
            
    end        
    
    div.add e
    doc.root.add div

    if a3.any? then

      style = "%s: %s%%; font-size: %s%%" % [ dimension, rem_pct.round, 
                                            rem_pct.round + 15]
      doc3 = Rexle.new("<div id='box%s' class='%s' style='%s'/>" % \
                       [@counter, klass, style])
      @counter += 1

      puts ('_rem_pct: ' + rem_pct.inspect).debug if @debug
      doc2 = mapper(doc3, a3, orientation: new_orientation, total: remainder)
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
