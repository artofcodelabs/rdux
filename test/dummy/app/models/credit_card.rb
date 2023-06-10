class CreditCard < ApplicationRecord
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :last_four, presence: true
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :token, presence: true, if: -> { !validation_context.is_a?(Hash) || validation_context[:context] != :before_request_gateway }
  validates :user, presence: true

  def number
    "**** **** **** #{last_four}"
  end

  def number=(val)
    self.last_four = val.to_s[-4..]
  end
end
