# frozen_string_literal: true

module Rdux
  module SafePayload
    extend ActiveSupport::Concern

    included do
      attr_accessor :payload_unsanitized
    end

    def only_sanitized_payload?
      payload_sanitized && payload_unsanitized.nil?
    end

    def safe_payload
      payload_unsanitized || payload
    end
  end
end
