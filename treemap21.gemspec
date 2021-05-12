Gem::Specification.new do |s|
  s.name = 'treemap21'
  s.version = '0.2.0'
  s.summary = 'Experimental treemapping gem which generates an HTML document.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/treemap21.rb']
  s.add_runtime_dependency('polyrex', '~> 1.3', '>=1.3.1')
  s.signing_key = '../privatekeys/treemap21.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/treemap21'
end
