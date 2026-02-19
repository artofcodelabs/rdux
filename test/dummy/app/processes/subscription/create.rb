# frozen_string_literal: true

module Processes
  module Subscription
    module Create
      ACTIONS = [
        { name: ::Subscription::Preview },
        { name: User::Create },
        { name: CreditCard::Create },
        { name: Payment::Create },
        { name: ::Subscription::Create }
      ].freeze

      def self.payload_for_action(payload:, name:, prev_result:) # rubocop:disable Metrics/MethodLength
        case name
        when 'Subscription::Preview'
          payload.slice('plan_id', 'user', 'total_cents')
        when 'User::Create'
          payload.slice('user')
        when 'CreditCard::Create'
          payload.slice('credit_card').merge(user_id: prev_result.val[:user_id])
        when 'Payment::Create'
          { token: prev_result.val[:credit_card].token }
        when 'Subscription::Create'
          payload.slice('plan_id').merge(ext_charge_id: prev_result.val[:charge_id])
        else
          payload
        end
      end
    end
  end
end
