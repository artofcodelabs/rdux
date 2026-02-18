# frozen_string_literal: true

module Rdux
  class Process < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    include SafePayload

    has_many :actions, class_name: 'Rdux::Action', foreign_key: 'rdux_process_id', inverse_of: :process,
                       dependent: :nullify

    if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
      serialize :payload, coder: JSON
      serialize :steps, coder: JSON
    end

    validates :payload, presence: true
    validate :steps_must_be_array

    before_validation do
      self.steps = steps_def
    end

    def payload_selector
      return unless performer.respond_to?(:payload_for_action)

      lambda { |name, payload, prev_result, action_index|
        kwargs = { name:, payload: }
        kwargs[:prev_result] = prev_result if accepts_param?(:prev_result)
        kwargs[:action_index] = action_index if accepts_param?(:action_index)
        payload_for_action.call(**kwargs)
      }
    end

    def resume(action)
      return unless action.ok

      ok_actions_count = actions.ok.count
      update!(ok: true) && return if ok_actions_count == steps_def.size

      step_performer = steps_def[ok_actions_count]
      Step.new(step_performer, process: self).call(prev_res: nil, action_index: ok_actions_count)
    end

    def call
      steps.each_with_index.reduce(nil) do |prev_res, (step, index)|
        step_performer = step.is_a?(Hash) ? steps_def[index] : step
        res = Step.new(step_performer, process: self).call(prev_res:, action_index: index)
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

    def payload_for_action
      performer.method(:payload_for_action)
    end

    def steps_def
      performer::STEPS.map { _1.is_a?(Hash) ? _1[:name] : _1 }
    end

    def accepts_param?(param)
      payload_for_action.parameters.any? do |type, name|
        %i[keyreq].include?(type) && name == param
      end
    end
  end
end
