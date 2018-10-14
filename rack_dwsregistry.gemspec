Gem::Specification.new do |s|
  s.name = 'rack_dwsregistry'
  s.version = '0.4.0'
  s.summary = 'Provides dws-registry gem functionality from behind a Rack webserver.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rack_dwsregistry.rb']
  s.add_runtime_dependency('rack', '~> 2.0', '>=2.0.5')
  s.add_runtime_dependency('app-routes', '~> 0.1', '>=0.1.19') 
  s.add_runtime_dependency('rexle', '~> 1.4', '>=1.4.13') 
  s.signing_key = '../privatekeys/rack_dwsregistry.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/rack_dwsregistry'
end
