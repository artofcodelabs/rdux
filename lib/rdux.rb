# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/migration_helpers'
require 'rdux/result'
require 'rdux/sanitize'
require 'rdux/dispatching'
require 'rdux/processing'

module Rdux
  extend Dispatching
  extend Processing
end
