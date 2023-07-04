# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true, inclusion: { in: %w[gold premium] }
  validates :ext_charge_id, presence: true
end
