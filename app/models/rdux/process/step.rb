# frozen_string_literal: true

module Rdux
  class Process
    class Step
      def initialize(action_performer, process:)
        @action_performer = action_performer
        @process = process
      end

      def call(prev_res:, action_index:)
        step_payload = if payload_selector
                         payload_selector.call(@action_performer, payload, prev_res,
                                               action_index)
                       else
                         payload
                       end
        if @action_performer.is_a?(Proc)
          @action_performer.call(step_payload, @process)
          return Rdux::Result[ok: nil]
        end

        res = Rdux.perform(@action_performer, step_payload, { process: @process })
        res.action.process = @process
        res.action.save!
        res
      end

      private

      def payload
        @process.safe_payload
      end

      def payload_selector
        @process.payload_selector
      end
    end
  end
end
