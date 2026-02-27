# frozen_string_literal: true

module Rdux
  class Process
    class Step
      # TODO: remove
      def self.call(action_performer:, action_payload:, process:, attach_to_process:)
        if action_performer.is_a?(Proc)
          action_performer.call(action_payload, process)
          return Rdux::Result[ok: nil]
        end

        opts = { process: }
        res = if attach_to_process
                Rdux.perform(action_performer, action_payload, opts, process:)
              else
                Rdux.perform(action_performer, action_payload, opts)
              end
        res.action.process = process
        res.action.save!
        res
      end
    end
  end
end
