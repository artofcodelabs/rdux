# frozen_string_literal: true

module Payment
  module Create
    def self.call(payload, opts)
      total_cents = opts[:process].actions.find_by(name: 'Subscription::Preview').result['total_cents']
      res = PaymentGateway.charge(payload['token'], total_cents)
      Rdux::Result[ok: true, val: { charge_id: res[:id] }]
    end
  end
end
