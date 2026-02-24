# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload, process|
          payload = payload.slice('plan_id', 'user', 'total_cents')
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        lambda { |payload, process|
          payload = payload.slice('user')
          Rdux.perform(User::Create, payload, process:)
        }
      ].freeze
    end
  end
end
