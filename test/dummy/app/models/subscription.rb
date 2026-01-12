# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  validates :user_id, presence: true
  validates :plan_id, presence: true
  validates :ext_charge_id, presence: true
end
