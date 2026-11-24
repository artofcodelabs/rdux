# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'rdux/version'

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

  spec.required_ruby_version = '>= 3.3.8'

  spec.add_dependency 'rails', '>= 8.0', '< 9.0'

  spec.add_development_dependency 'pg', '>= 1.7.0'
  spec.add_development_dependency 'rubocop', '>= 1.92.3'
  spec.add_development_dependency 'rubocop-rails', '>= 2.38.0'
  spec.add_development_dependency 'sqlite3', '>= 2.10.2'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
