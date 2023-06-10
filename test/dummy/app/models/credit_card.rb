# frozen_string_literal: true

class CreditCard < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :last_four, presence: true
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :token, presence: true, if: :not_before_request_gateway?
  validates :user, presence: true

  def number
    "**** **** **** #{last_four}"
  end

  def number=(val)
    self.last_four = val.to_s[-4..]
  end

  private

  def not_before_request_gateway?
    return false unless validation_context.is_a?(Hash)

    validation_context[:context] != :before_request_gateway
  end
end
