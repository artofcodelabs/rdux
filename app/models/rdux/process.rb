# frozen_string_literal: true

module Rdux
  class Process < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    has_many :actions, class_name: 'Rdux::Action', foreign_key: 'rdux_process_id', inverse_of: :process,
                       dependent: :nullify

    serialize :steps, coder: JSON if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'

    validate :steps_must_be_array

    private

    def steps_must_be_array
      unless steps.is_a?(Array)
        errors.add(:steps, 'must be an Array')
        return
      end

      errors.add(:steps, 'must include at least 1 step') if steps.empty?
    end
  end
end
