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
