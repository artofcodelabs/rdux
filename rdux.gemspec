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
  spec.homepage    = 'https://github.com/artofcodelabs/rdux'
  spec.summary     = 'A Minimal Event Sourcing Plugin for Rails'
  spec.description = <<~DESC
    Rdux is a lightweight, minimalistic Rails plugin designed to introduce event sourcing and audit logging capabilities to your Rails application.#{' '}
    With Rdux, you can efficiently track and store the history of actions performed within your app, offering transparency and traceability for key processes.
  DESC
  spec.license = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 3.1.2'

  spec.add_dependency 'rails', '>= 7.0', '< 9.0'

  spec.add_development_dependency 'pg', '>= 1.6.2'
  spec.add_development_dependency 'rubocop', '>= 1.80.2'
  spec.add_development_dependency 'rubocop-rails', '>= 2.33.3'
  spec.add_development_dependency 'sqlite3', '>= 2.7.4'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
