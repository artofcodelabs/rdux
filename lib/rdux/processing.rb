# frozen_string_literal: true

module Rdux
  module Processing
    def start(process_performer, payload)
      payload = payload.deep_stringify_keys
      process = Process.create!(name: process_performer, steps: process_performer::STEPS)
      selector = payload_selector_for(process_performer)
      res = call_steps(process, payload, payload_selector: selector)
      process.update!(ok: res.ok) unless res.ok.nil?
      res
    end

    private

    def payload_selector_for(process_performer)
      return unless process_performer.respond_to?(:payload_for_action)

      lambda { |action_name, payload, prev_result|
        process_performer.payload_for_action(action_name:, payload:, prev_result:)
      }
    end

    def call_steps(process, payload, payload_selector: nil) # rubocop:disable Metrics/MethodLength
      res = Result[val: { process: }]
      action_res = nil
      process.steps.each_with_index do |step, index|
        if step.is_a?(Hash)
          process.name.constantize::STEPS[index].call(payload)
          return res
        end
        action_res = call_step(step:, payload:, process:, payload_selector:, prev_res: action_res)
        unless action_res.ok
          res.ok = action_res.ok
          return res
        end
      end
      res.ok = true
      res
    end

    def call_step(step:, payload:, process:, payload_selector:, prev_res:)
      step_payload = payload_selector ? payload_selector.call(step, payload, prev_res) : payload
      res = Rdux.perform(step, step_payload, { process: })
      res.action.process = process
      res.action.save!
      res
    end
  end
end
