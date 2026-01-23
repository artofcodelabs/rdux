# frozen_string_literal: true

class Subscription
  module PreviewAsync
    def self.call(payload, opts)
      # dispatch background job -> action.resolve/reject -> process.resume
      Rdux::Result[ok: nil, save: true]
    end
  end
end
