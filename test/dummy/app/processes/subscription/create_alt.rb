# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAlt
      STEPS = [
        { name: ::Subscription::Preview,
          payload: ->(payload, _) { payload.slice('plan_id', 'user', 'total_cents') } },
        { name: User::Create,
          payload: ->(payload, _) { payload.slice('user') } },
        { name: CreditCard::Create,
          payload: ->(payload, prev_res) { payload.slice('credit_card').merge(user_id: prev_res.val[:user_id]) } },
        { name: Payment::Create,
          payload: ->(_, prev_res) { { token: prev_res.val[:credit_card].token } } },
        { name: ::Subscription::Create,
          payload: ->(payload, prev_res) { payload.slice('plan_id').merge(ext_charge_id: prev_res.val[:charge_id]) } }
      ].freeze
    end
  end
end
