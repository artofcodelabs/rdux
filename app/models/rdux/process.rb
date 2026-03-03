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
      return res unless res.ok

      ok_actions_count = actions.ok.count
      update!(ok: true) && return if ok_actions_count == steps.size

      call_step(index: ok_actions_count, prev_res: res)
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

    def action_payload(step_def:, prev_res:)
      step_def[:payload].is_a?(Proc) ? step_def[:payload].call(safe_payload, prev_res) : safe_payload
    end

    def call_step(index:, prev_res: nil)
      step_def = performer::STEPS[index]
      if steps[index].is_a?(Hash)
        step_def.call(safe_payload, self)
        return Rdux::Result[ok: nil]
      end

      action_payload = action_payload(step_def:, prev_res:)
      Rdux.perform(steps[index], action_payload, process: self)
    end
  end
end
