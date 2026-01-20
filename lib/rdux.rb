# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/store'
require 'rdux/result'
require 'rdux/dispatching'
require 'rdux/processing'

module Rdux
  extend Dispatching
  extend Processing
end
