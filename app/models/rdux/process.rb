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

    before_validation on: :create do
      self.steps = performer::STEPS.map { _1.is_a?(Hash) ? _1[:name] : _1 } if steps.empty?
    end

    def resume(res)
      return unless res.ok

      ok_actions_count = actions.ok.count
      update!(ok: true) && return if ok_actions_count == steps.size

      call_step(index: ok_actions_count, prev_res: res, attach_to_process: true)
    end

    def call
      steps.each_with_index.reduce(nil) do |prev_res, (step, index)|
        res = call_step(index:, step:, prev_res:, attach_to_process: false)
        break res if res.ok != true

        res
      end
    end

    private

    def steps_must_be_array
      if !steps.is_a?(Array)
        errors.add(:steps, 'must be an Array')
      elsif steps.empty?
        errors.add(:steps, 'must include at least 1 step')
      end
    end

    def performer
      name.constantize
    end

    def action_performer(index: nil, step: nil)
      step ||= steps[index]
      step.is_a?(Hash) ? performer::STEPS[index] : step
    end

    def action_payload(action_performer:, prev_res:, index:)
      return safe_payload if action_performer.is_a?(Proc)

      func = performer::STEPS[index][:payload]
      func.is_a?(Proc) ? func.call(safe_payload, prev_res) : safe_payload
    end

    def call_step(index:, step: nil, prev_res: nil, attach_to_process: false)
      action_performer = action_performer(index:, step:)
      action_payload = action_payload(action_performer:, prev_res:, index:)
      Step.call(action_performer:, payload: action_payload, process: self, attach_to_process:)
    end
  end
end
