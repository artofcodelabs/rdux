# frozen_string_literal: true

class CreditCard
  class Charge
    class << self
      def call(payload, opts = {})
        res = create(payload.slice('user_id', 'credit_card'), opts.slice(:user))
        return res unless res.ok

        charge = PaymentGateway.charge(res.payload.credit_card.token, payload['amount'])
        unless charge
          return Rdux::Result.new(ok: false,
                                  resp: { errors: { base: 'Invalid credit card' },
                                          save: true, nested: [res] })
        end

        Rdux::Result.new(ok: true, resp: { charge_id: charge.id }, nested: [res])
      end

      private

      def create(payload, opts)
        res = Rdux.dispatch(Create, payload, opts)
        return res if res.ok

        Rdux::Result.new(ok: false, resp: { errors: res.payload[:errors] }, save: true, nested: [res])
      end
    end
  end
end
