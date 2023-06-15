# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :start_at, presence: true

  class << self
    def current
      find_by(end_at: nil)
    end
  end

  before_validation do
    self.start_at ||= Time.current
  end
end
