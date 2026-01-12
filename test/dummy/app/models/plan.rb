# frozen_string_literal: true

class Plan < ApplicationRecord
  validates :name, presence: true, inclusion: { in: %w[gold premium] }
end
