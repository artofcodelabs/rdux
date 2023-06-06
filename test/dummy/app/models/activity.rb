class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :start_at, presence: true
end
