# frozen_string_literal: true

module Rdux
  module Store
    def self.call(name:, payload:, meta:, process:)
      action = Action.new(name:, payload:, meta:)
      action.process = process if process
      Sanitize.call(action)
      action
    end
  end
end
