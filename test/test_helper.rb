# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
require 'rails/test_help'
require 'minitest/spec'

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require 'rails/test_unit/reporter'
Rails::TestUnitReporter.executable = 'bin/test'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path('fixtures', __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_paths}/files"
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
    extend Minitest::Spec::DSL
  end
end

TC = ActiveSupport::TestCase
