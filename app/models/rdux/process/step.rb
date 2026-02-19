# frozen_string_literal: true

module Rdux
  class Process
    class Step
      def initialize(action_performer, process:)
        @action_performer = action_performer
        @process = process
      end

      def call(payload)
        if @action_performer.is_a?(Proc)
          @action_performer.call(payload, @process)
          return Rdux::Result[ok: nil]
        end

        res = Rdux.perform(@action_performer, payload, { process: @process })
        res.action.process = @process
        res.action.save!
        res
      end
    end
  end
end
