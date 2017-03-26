# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'firecord/version'

Gem::Specification.new do |spec|
  spec.name          = 'firecord'
  spec.version       = Firecord::VERSION
  spec.authors       = ['Tomas Koutsky']
  spec.email         = ['tomas@stepnivlk.net']

  spec.summary       = 'Firecord is an ODM framework for Firebase in Ruby.'
  spec.description   = 'Firecord is an ODM (Object-Document-Mapper) framework' \
                       ' for Firebase in Ruby.'
  spec.homepage      = "http://stepnivlk.net"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'jwt', '~> 1.5.6'
  spec.add_runtime_dependency 'httparty', '~> 0.14.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3.2'
  spec.add_development_dependency 'vcr', '~> 3.0.3'
end
