# frozen_string_literal: true

require_relative 'boot'

%w[
  active_record/railtie
  rails/test_unit/railtie
].each do |railtie|
  require railtie
end

Bundler.require(*Rails.groups)
require 'rudux'

module Dummy
  class Application < Rails::Application
    config.load_defaults 6.0
  end
end
