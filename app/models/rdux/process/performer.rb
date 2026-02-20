# frozen_string_literal: true

module Rdux
  class Process
    class Performer
      def initialize(performer)
        @performer = performer
      end

      def payload_selector
        lambda { |name, payload, prev_result, action_index|
          kwargs = { name:, payload: }
          kwargs[:prev_result] = prev_result if accepts_param?(:prev_result)
          kwargs[:action_index] = action_index if accepts_param?(:action_index)
          payload_for_action_method.call(**kwargs)
        }
      end

      def payload_for_action_method
        return unless @performer.respond_to?(:payload_for_action)

        @performer.method(:payload_for_action)
      end

      private

      def accepts_param?(param)
        payload_for_action_method.parameters.any? do |type, name|
          %i[keyreq].include?(type) && name == param
        end
      end
    end
  end
end
