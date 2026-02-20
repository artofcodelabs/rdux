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
      self.steps = performer::ACTIONS.map { _1.is_a?(Hash) ? _1[:name] : _1 } if steps.empty?
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
      update!(ok: true) && return if ok_actions_count == steps.size

      call_step(index: ok_actions_count)
    end

    def call
      steps.each_with_index.reduce(nil) do |prev_res, (current_step, index)|
        res = call_step(index:, step: current_step, prev_res:)
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

    def payload_for_action
      performer.method(:payload_for_action)
    end

    def action_performer(index: nil, step: nil)
      step ||= steps[index]
      step.is_a?(Hash) ? performer::ACTIONS[index] : step
    end

    def action_payload(action_performer:, prev_res:, index:)
      if payload_selector
        payload_selector.call(action_performer, safe_payload, prev_res, index)
      else
        safe_payload
      end
    end

    def accepts_param?(param)
      payload_for_action.parameters.any? do |type, name|
        %i[keyreq].include?(type) && name == param
      end
    end

    def call_step(index:, step: nil, prev_res: nil)
      action_performer = action_performer(index:, step:)
      action_payload = action_payload(action_performer:, prev_res:, index:)
      Step.new(action_performer, process: self).call(action_payload)
    end
  end
end
