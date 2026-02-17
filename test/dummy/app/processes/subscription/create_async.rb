# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload, process|
          # TODO: reduce payload here?
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        User::Create
      ].freeze

      def self.payload_for_action(payload:, action_name:, action_index:) # rubocop:disable Metrics/MethodLength
        case action_name
        when 'User::Create'
          payload.slice('user')
        else
          case action_index
          when 0
            payload.slice('plan_id', 'user', 'total_cents')
          else
            payload
          end
        end
      end
    end
  end
end
