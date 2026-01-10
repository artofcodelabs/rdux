# frozen_string_literal: true

module Rdux
  class Process < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    has_many :actions, class_name: 'Rdux::Action', foreign_key: 'rdux_process_id', inverse_of: :process,
                       dependent: :nullify

    if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
      serialize :steps, coder: JSON
    end

    validate :steps_must_be_array

    private

    def steps_must_be_array
      errors.add(:steps, 'must be an Array') unless steps.is_a?(Array)
    end
  end
end
