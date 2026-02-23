# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload, process|
          payload = payload.slice('plan_id', 'user', 'total_cents')
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        { name: User::Create, payload: ->(payload, _) { payload.slice('user') } }
      ].freeze
    end
  end
end
