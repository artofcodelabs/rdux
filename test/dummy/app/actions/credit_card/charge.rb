# frozen_string_literal: true

class CreditCard
  class Charge
    class << self
      def call(payload, opts = {})
        create_res = create(payload.slice('user_id', 'credit_card'), opts.slice(:user))
        return create_res unless create_res.ok

        charge(create_res, payload['amount'])
      end

      private

      def create(payload, opts)
        res = Rdux.perform(Create, payload, opts)
        return res if res.ok

        Rdux::Result[ok: false, val: { errors: res.val[:errors] }, save: true, nested: [res]]
      end

      def charge(create_res, amount)
        token = create_res.val[:credit_card].token
        res = PaymentGateway.charge(token, amount)
        if res[:id].nil?
          Rdux::Result[ok: false, val: { errors: { base: 'Invalid credit card' } }, save: true,
                       nested: [create_res]]
        else
          Rdux::Result[ok: true, val: { charge_id: res[:id] }, nested: [create_res]]
        end
      end
    end
  end
end
