Gem::Specification.new do |s|
  s.name = 'treemap21'
  s.version = '0.1.1'
  s.summary = 'Experimental treemapping gem which generates an HTML document.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/treemap21.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.11')
  s.signing_key = '../privatekeys/treemap21.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/treemap21'
end
