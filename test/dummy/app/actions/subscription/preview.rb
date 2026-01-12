# frozen_string_literal: true

class Subscription
  module Preview
    def self.call(_payload)
      Rdux::Result[ok: true]
    end
  end
end
