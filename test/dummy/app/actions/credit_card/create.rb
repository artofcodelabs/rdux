# frozen_string_literal: true

class CreditCard
  class Create
    class << self
      def up(payload, opts = {})
        user = opts[:user] || User.find(payload['user_id'])
        card = user.credit_cards.new(payload['credit_card'])
        return Rdux::Result.new(false, { errors: card.errors }) if card.invalid?(context: :before_request_gateway)

        token = PaymentGateway.tokenize(card)
        return Rdux::Result.new(false, { errors: { base: 'Invalid credit card' } }) unless token

        card.token = token
        save_credit_card(card)
      end

      def down(payload)
        cc = CreditCard.find(payload['credit_card_id'])
        PaymentGateway.delete_credit_card(cc.token)
        CreditCard.find(cc.id).destroy
      end

      private

      def save_credit_card(card)
        if card.save
          Rdux::Result.new(true, { credit_card_id: card.id }, { id: card.id })
        else
          Rdux::Result.new(false, { errors: card.errors })
        end
      end
    end
  end
end
