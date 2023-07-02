# frozen_string_literal: true

module Rdux
  class FailedAction < ApplicationRecord
    include Actionable

    belongs_to :rdux_failed_action, optional: true, class_name: 'Rdux::FailedAction'
    has_many :rdux_failed_actions, class_name: 'Rdux::FailedAction', foreign_key: 'rdux_failed_action_id'
  end
end
