# frozen_string_literal: true

class Plan
  class Create
    def self.call(payload, opts = {})
      res = Rdux.perform(CreditCard::Charge, payload.slice('user_id', 'credit_card', 'amount'), opts.slice(:user))
      Rdux::Result[ok: false, val: { errors: res.val[:errors] }, save: true, nested: [res]] unless res.ok
    end
  end
end
