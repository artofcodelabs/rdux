# frozen_string_literal: true

class CreditCard::Create
  def self.up(payload, opts = {})
    user = opts[:user] || User.find(payload['user_id'])
    card = user.credit_cards.new(payload['credit_card'])
    if card.valid?(context: :before_request_gateway)
      card.token = PaymentGateway.tokenize(card)
    end
    if card.save
      Rdux::Result.new(true, { credit_card_id: card.id }, { id: card.id })
    else
      Rdux::Result.new(false, { errors: card.errors })
    end
  end

  def self.down(payload)
    CreditCard.find(payload['credit_card_id']).destroy
  end
end
