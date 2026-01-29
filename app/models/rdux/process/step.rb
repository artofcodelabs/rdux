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
          @step.call(@process.payload, prev_res)
          return Rdux::Result[ok: nil]
        end

        step_payload = if @process.payload_selector
                         @process.payload_selector.call(@step, @process.payload,
                                                        prev_res)
                       else
                         @process.payload
                       end
        res = Rdux.perform(@step, step_payload, { process: @process })
        res.action.process = @process
        res.action.save!
        res
      end
    end
  end
end
