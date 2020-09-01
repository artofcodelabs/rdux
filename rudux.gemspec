# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'rudux/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'rudux'
  spec.version     = Rudux::VERSION
  spec.authors     = ['Zbigniew Humeniuk']
  spec.email       = ['hello@artofcode.co']
  spec.homepage    = 'https://artofcode.co'
  spec.summary     = 'Rudux adds a new layer to Rails apps - actions.'
  spec.description = <<~DESC
    Write apps that are easy to test.
    Rudux gives you a possibility to centralize your app's state modification logic (DB changes).
    It enables powerful capabilities like undo/redo.
    Rudux makes it easy to trace when, where, why, and how your application's state changed.
  DESC
  spec.license = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_dependency 'rails', '>= 5.0', '< 7.0'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'sqlite3'
end
