# frozen_string_literal: true

module Rdux
  module Sanitize
    def self.call(ar)
      param_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      payload_sanitized = param_filter.filter(ar.payload)
      ar.payload_sanitized = ar.payload != payload_sanitized
      ar.payload_unsanitized = ar.payload if ar.payload_sanitized
      ar.payload = payload_sanitized
    end
  end
end
