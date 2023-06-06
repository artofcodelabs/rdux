# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :start_at, presence: true

  before_validation do
    self.start_at ||= Time.current
  end
end
