# frozen_string_literal: true

module Rdux
  class Process
    class Step
      def self.call(action_performer:, action_payload:, process:)
        if action_performer.is_a?(Proc)
          action_performer.call(action_payload, process)
          return Rdux::Result[ok: nil]
        end

        res = Rdux.perform(action_performer, action_payload, { process: })
        res.action.process = process
        res.action.save!
        res
      end
    end
  end
end
