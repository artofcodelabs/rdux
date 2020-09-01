# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
end
