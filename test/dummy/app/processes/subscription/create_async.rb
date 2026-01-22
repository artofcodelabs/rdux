# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [::Subscription::PreviewAsync].freeze

      def self.payload_for_action(payload:, action_name:, prev_result:)
        case action_name
        when 'Subscription::PreviewAsync'
          payload.slice('plan_id', 'user', 'total_cents')
        else
          payload
        end
      end
    end
  end
end
