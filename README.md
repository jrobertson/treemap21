# Treemap21: String input with a tree format

    require 'treemap21'

    s = "
    Company 101 # 34 # http://a0.jamesrobertson.me.uk
    Group A # 33 # #groupa
      Company 301 # 444 # #company301
      Company 401 # 200 # #company401
    "

    tm = Treemap21.new s, debug: true
    puts tm.to_html
    File.write '/tmp/treemap.html', tm.to_html
    `chromium /tmp/treemap.html`

treemap treemap21 tree

----------------------------------------------

# Introducing the Treemap21 gem

## Usage

    require 'treemap21'

    a = [['company 600', 20], ['company 100', 60], ['company 300', 10], ['company 550', 5], ['company 570', 5]]
    tm = Treemap21.new a, debug: false

    File.write '/tmp/treemap.html', tm.to_html
    `chromium /tmp/treemap.html`

## Resources

* treemap21 https://rubygems.org/gems/treemap21

treemap treemap21 treemapping tree graph gem
