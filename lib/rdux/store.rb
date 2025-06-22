# frozen_string_literal: true

module Rdux
  module Store
    class << self
      def call(name, payload, meta)
        action = Action.new(name:, payload:, meta:)
        sanitize(action)
        action.save!
        action
      end

      private

      def sanitize(action)
        param_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
        payload_sanitized = param_filter.filter(action.payload)
        action.payload_sanitized = action.payload != payload_sanitized
        action.payload_unsanitized = action.payload if action.payload_sanitized
        action.payload = payload_sanitized
      end
    end
  end
end
