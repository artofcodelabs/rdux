# frozen_string_literal: true

module PaymentGateway
  def self.tokenize(credit_card)
    SecureRandom.hex(16)
  end
end