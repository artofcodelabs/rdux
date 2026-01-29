# frozen_string_literal: true

module Rdux
  module SafePayload
    extend ActiveSupport::Concern

    included do
      attr_accessor :payload_unsanitized
    end

    def safe_payload
      payload_unsanitized || payload
    end
  end
end
