# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'site_mapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'site_mapper'
  spec.version       = SiteMapper::VERSION
  spec.authors       = ['Jacob Burenstam']
  spec.email         = ['burenstam@gmail.com']

  spec.summary       = %q{Map all links on a given site.}
  spec.description   = %q{Map all links on a given site.}
  spec.homepage      = 'https://github.com/buren/site_mapper'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{bin,lib}/**/*")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_runtime_dependency 'nokogiri',      '~> 1.6'
  spec.add_runtime_dependency 'url_resolver',  '~> 0.1'

  spec.add_development_dependency 'bundler',   '~> 1.3'
  spec.add_development_dependency 'rake',      '~> 10.3'
  spec.add_development_dependency 'rspec',     '~> 3.1'
  spec.add_development_dependency 'yard',      '~> 0.8'
  spec.add_development_dependency 'coveralls', '~> 0.7'
end
