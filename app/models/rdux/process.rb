# frozen_string_literal: true

module Rdux
  class Process < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    has_many :actions, class_name: 'Rdux::Action', foreign_key: 'rdux_process_id', inverse_of: :process,
                       dependent: :nullify

    if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
      serialize :payload, coder: JSON
      serialize :steps, coder: JSON
    end

    validates :payload, presence: true
    validate :steps_must_be_array

    def payload_selector
      return unless performer.respond_to?(:payload_for_action)

      lambda { |action_name, payload, prev_result|
        performer.payload_for_action(action_name:, payload:, prev_result:)
      }
    end

    def resume(action)
      return unless action.ok

      ok_actions_count = actions.ok.count
      update!(ok: true) && return if ok_actions_count == steps_def.size

      steps_def[ok_actions_count]
      # TODO: call next step asynchronously
    end

    def process_steps
      steps.each_with_index.reduce(nil) do |prev_res, (step, index)|
        step_performer = step.is_a?(Hash) ? steps_def[index] : step
        res = Step.new(step_performer, process: self).call(prev_res:)
        break res if res.ok != true

        res
      end
    end

    private

    def steps_must_be_array
      unless steps.is_a?(Array)
        errors.add(:steps, 'must be an Array')
        return
      end

      errors.add(:steps, 'must include at least 1 step') if steps.empty?
    end

    def performer
      name.constantize
    end

    def steps_def
      performer::STEPS
    end
  end
end
