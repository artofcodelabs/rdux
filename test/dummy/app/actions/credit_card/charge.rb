# frozen_string_literal: true

class CreditCard
  class Charge
    class << self
      def call(payload, opts = {})
        create_res = create(payload.slice('user_id', 'credit_card'), opts.slice(:user))
        return create_res unless create_res.ok

        charge(create_res.payload[:credit_card].token, payload['amount'], create_res)
      end

      private

      def create(payload, opts)
        res = Rdux.dispatch(Create, payload, opts)
        return res if res.ok

        Rdux::Result.new(ok: false, resp: { errors: res.payload[:errors] }, save: true, nested: [res])
      end

      def charge(token, amount, create_res)
        res = PaymentGateway.charge(token, amount)
        if res[:id].nil?
          Rdux::Result.new(ok: false, resp: { errors: { base: 'Invalid credit card' } }, save: true,
                           nested: [create_res])
        else
          Rdux::Result.new(ok: true, resp: { charge_id: res[:id] }, nested: [create_res])
        end
      end
    end
  end
end
