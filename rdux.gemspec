# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'rdux/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'rdux'
  spec.version     = Rdux::VERSION
  spec.authors     = ['Zbigniew Humeniuk']
  spec.email       = ['hello@artofcode.co']
  spec.homepage    = 'https://artofcode.co'
  spec.summary     = 'Rdux adds a new layer to Rails apps - actions.'
  spec.description = <<~DESC
    ...
  DESC
  spec.license = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 3.1.2'

  spec.add_dependency 'rails', '>= 5.0', '< 8.0'

  spec.add_development_dependency 'pg', '>= 1.5.4'
  spec.add_development_dependency 'rubocop', '>= 1.59.0'
  spec.add_development_dependency 'rubocop-rails', '>= 2.23.1'
  spec.add_development_dependency 'sqlite3', '>= 1.7.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
