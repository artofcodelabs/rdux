# frozen_string_literal: true

class Subscription
  module Create
    def self.call(payload, opts)
      user_id = opts[:process].actions.find_by(name: 'User::Create').result['user_id']
      Subscription.create!(
        plan_id: payload['plan_id'],
        ext_charge_id: payload['ext_charge_id'],
        user_id:
      )
      Rdux::Result[ok: true]
    end
  end
end
