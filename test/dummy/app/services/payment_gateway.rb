# frozen_string_literal: true

module PaymentGateway
  def self.tokenize(credit_card)
    return false unless credit_card.number.match?(/\A\d{16}\z/)

    (0...4).map { rand(36).to_s(36) }.join + credit_card.number.to_s[-4..]
  end

  def self.delete_credit_card(token)
    token
  end
end
