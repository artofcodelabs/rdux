# frozen_string_literal: true

module Rdux
  module Sanitize
    def self.call(aro)
      param_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      payload_sanitized = param_filter.filter(aro.payload)
      aro.payload_sanitized = aro.payload != payload_sanitized
      aro.payload_unsanitized = aro.payload if aro.payload_sanitized
      aro.payload = payload_sanitized
    end
  end
end
