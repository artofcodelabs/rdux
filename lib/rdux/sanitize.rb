# frozen_string_literal: true

module Rdux
  module Sanitize
    class << self
      def call(payload)
        filter_parameters = Rails.application.config.filter_parameters
        compiled = if Rails.application.config.precompile_filter_parameters
                     filter_parameters
                   else
                     ActiveSupport::ParameterFilter.precompile_filters(filter_parameters)
                   end
        ActiveSupport::ParameterFilter.new(compiled).filter(payload.deep_dup)
      end
    end
  end
end
