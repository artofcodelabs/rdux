# frozen_string_literal: true

module PaymentGateway
  def self.tokenize(credit_card)
    (0...4).map { rand(36).to_s(36) }.join + credit_card.number.to_s[-4..]
  end
end
