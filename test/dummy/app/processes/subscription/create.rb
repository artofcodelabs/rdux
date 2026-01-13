# frozen_string_literal: true

module Processes
  module Subscription
    module Create
      STEPS = [
        ::Subscription::Preview,
        # Customer::Create,
        CreditCard::Create
        # Payment::Create,
        # Create,
        # Invoice::Create
      ].freeze

      module_function

      def payload_for_action(action_name, payload)
        case action_name
        when 'Subscription::Preview'
          payload.slice('plan_id', 'customer')
        when 'CreditCard::Create'
          payload.slice('user_id', 'credit_card')
        else
          payload
        end
      end
    end
  end
end
