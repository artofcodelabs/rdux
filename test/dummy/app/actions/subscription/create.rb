# frozen_string_literal: true

class Subscription
  module Create
    def self.call(payload)
      Rdux::Result[ok: true]
    end
  end
end
