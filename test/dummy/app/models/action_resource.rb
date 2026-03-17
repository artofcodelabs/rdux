# frozen_string_literal: true

class ActionResource < ApplicationRecord
  belongs_to :action, class_name: 'Rdux::Action'
  belongs_to :resource, polymorphic: true

  validates :action_id, uniqueness: { scope: %i[resource_type resource_id] }
  validates :resource_type, presence: true
end
