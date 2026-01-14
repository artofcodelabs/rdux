# frozen_string_literal: true

module Rdux
  module Processing
    module_function

    def payload_selector_for(process_performer)
      return unless process_performer.respond_to?(:payload_for_action)

      lambda { |action_name, payload, prev_result|
        process_performer.payload_for_action(action_name:, payload:, prev_result:)
      }
    end

    def call_steps(process, payload, payload_selector: nil)
      res = nil
      process.steps.each do |step|
        step_payload = payload_selector ? payload_selector.call(step, payload, res) : payload
        res = Rdux.perform(step, step_payload)
        res.action.process = process
        res.action.save!
        break unless res.ok
      end
      res
    end
  end
end
