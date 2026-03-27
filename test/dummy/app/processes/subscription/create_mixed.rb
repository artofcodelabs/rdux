# frozen_string_literal: true

module Processes
  module Subscription
    module CreateMixed
      STEPS = [
        lambda { |payload, process|
          payload = payload.slice('plan_id', 'user', 'total_cents')
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        lambda { |payload, process|
          payload = payload.slice('user')
          Rdux.perform(User::Create, payload, process:)
        },
        { name: CreditCard::Create,
          payload: lambda { |payload, prev_res|
            payload.slice('credit_card').merge(user_id: prev_res.action.result['user_id'])
          } },
        { name: Payment::Create,
          payload: ->(_, prev_res) { { token: prev_res.val[:credit_card].token } } },
        { name: ::Subscription::Create,
          payload: ->(payload, prev_res) { payload.slice('plan_id').merge(ext_charge_id: prev_res.val[:charge_id]) } }
      ].freeze
    end
  end
end
