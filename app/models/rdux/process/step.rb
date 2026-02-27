# frozen_string_literal: true

module Rdux
  class Process
    class Step
      # TODO: remove
      def self.call(action_performer:, payload:, process:, attach_to_process:)
        if action_performer.is_a?(Proc)
          action_performer.call(payload, process)
          return Rdux::Result[ok: nil]
        end

        opts = { process: }
        res = if attach_to_process
                Rdux.perform(name: action_performer, payload:, opts:, process:)
              else
                Rdux.perform(name: action_performer, payload:, opts:)
              end
        res.action.process = process
        res.action.save!
        res
      end
    end
  end
end
