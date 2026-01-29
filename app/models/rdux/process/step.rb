# frozen_string_literal: true

module Rdux
  class Process
    class Step
      def initialize(step, process:)
        @step = step
        @process = process
      end

      def call(prev_res:)
        if @step.is_a?(Proc)
          @step.call(payload, prev_res)
          return Rdux::Result[ok: nil]
        end

        step_payload = payload_selector ? payload_selector.call(@step, payload, prev_res) : payload
        res = Rdux.perform(@step, step_payload, { process: @process })
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
