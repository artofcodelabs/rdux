# frozen_string_literal: true

module Processes
  module Subscription
    module Create
      STEPS = [
        ::Subscription::Preview,
        User::Create,
        CreditCard::Create
        # Payment::Create,
        # Create,
        # Invoice::Create
      ].freeze

      module_function

      def payload_for_action(action_name:, payload:, prev_result:)
        case action_name
        when 'Subscription::Preview'
          payload.slice('plan_id', 'user')
        when 'User::Create'
          payload.slice('user')
        when 'CreditCard::Create'
          payload.slice('credit_card').merge(user_id: prev_result.val[:user_id])
        else
          payload
        end
      end
    end
  end
end
