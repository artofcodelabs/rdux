# frozen_string_literal: true

module Subscription
  module Preview
    def self.call(_payload)
      Rdux::Result[ok: true]
    end
  end
end
