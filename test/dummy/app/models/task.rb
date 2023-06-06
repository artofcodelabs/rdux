# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user
  has_many :activities, dependent: :destroy

  validates :name, presence: true
end
