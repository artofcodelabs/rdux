# frozen_string_literal: true

module PaymentGateway
  class << self
    def tokenize(credit_card)
      return false unless credit_card.number.match?(/\A\d{16}\z/)

      (0...4).map { rand(36).to_s(36) }.join + credit_card.number.to_s[-4..]
    end

    def delete_credit_card(token)
      token
    end

    def charge(token, amount)
      return false unless token.match?(/\A\w{8}\z/)
      raise('Negative amount') if amount.negative?

      failure = (amount * 100).to_i == 9999
      { id: failure ? nil : rand(1000), token:, amount: }
    end
  end
end
