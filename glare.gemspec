# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glare/version'

Gem::Specification.new do |spec|
  spec.name          = 'glare'
  spec.version       = Glare::VERSION
  spec.authors       = ['Jose Luis Salas', 'Omar Lopez']
  spec.email         = ['josacar@users.noreply.github.com', 'olopez@users.noreply.github.com']

  spec.summary       = 'API client for CloudFlare v4 API'
  spec.homepage      = 'https://github.com/peertransfer/glare'
  spec.license       = 'MIT'

  files = Dir['lib/**/*.rb']
  rootfiles = ['Gemfile', 'glare.gemspec', 'README.md', 'LICENSE']
  dotfiles = ['.gitignore', '.rspec']

  spec.files = files + rootfiles + dotfiles
  spec.test_files = Dir['spec/**/*.{rb,json}']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.9'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'

  spec.add_dependency 'faraday', '>= 0.16.0'
  spec.add_dependency 'faraday_middleware', '>= 0.13.0'
  spec.add_dependency 'httpx', '>= 0.6.6'
  spec.add_dependency 'public_suffix', '>= 3.0.2', '< 5.0'
end
