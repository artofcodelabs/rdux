# frozen_string_literal: true

module Rdux
  module Sanitize
    class << self
      def call(payload)
        filtered_payload = payload.deep_dup # Create a duplicate to avoid modifying the original params
        Rails.application.config.filter_parameters.each do |filter_param|
          filter_recursive(filtered_payload, filter_param)
        end
        filtered_payload
      end

      private

      def filter_recursive(payload, filter_param)
        payload.each do |key, value|
          if value.is_a? Hash # If the value is a nested parameter
            filter_recursive(value, filter_param)
          elsif key == filter_param.to_s # to_s is used to ensure that symbol/string difference does not matter
            payload[key] = '[FILTERED]'
          end
        end
      end
    end
  end
end
