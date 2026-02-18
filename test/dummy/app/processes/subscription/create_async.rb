# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload, process|
          payload = payload.slice('plan_id', 'user', 'total_cents')
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        User::Create
      ].freeze

      def self.payload_for_action(payload:, action_name:)
        case action_name
        when 'User::Create'
          payload.slice('user')
        else
          payload
        end
      end
    end
  end
end
