# frozen_string_literal: true

class CreditCard
  class Charge
    class << self
      def call(payload, opts)
        create_res = create(payload.slice('user_id', 'credit_card'), opts.slice(:user))
        return create_res unless create_res.ok

        opts[:result] = { credit_card_create_action_id: create_res.action.id }
        charge_id = PaymentGateway.charge(create_res.val[:credit_card].token, payload['amount'])[:id]
        if charge_id.nil?
          Rdux::Result[ok: false, val: { errors: { base: 'Invalid credit card' } }, save: true,
                       nested: [create_res]]
        else
          Rdux::Result[ok: true, val: { charge_id: }, nested: [create_res]]
        end
      end

      private

      def create(payload, opts)
        res = Rdux.perform(Create, payload, opts)
        res.ok ? res : Rdux::Result[ok: false, val: { errors: res.val[:errors] }, save: true]
      end
    end
  end
end
