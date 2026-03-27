# frozen_string_literal: true

class User < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
end
