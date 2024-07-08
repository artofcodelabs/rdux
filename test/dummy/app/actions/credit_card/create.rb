# frozen_string_literal: true

class CreditCard
  class Create
    AFTER_SAVE = lambda { |failed_action|
      if failed_action.meta['inc']
        failed_action.meta['inc'] += 10
        failed_action.save!
      end
    }

    class << self
      def up(payload, opts = {})
        user = opts[:user] || User.find(payload['user_id'])
        card = user.credit_cards.new(payload['credit_card'])
        if card.invalid?(context: :before_request_gateway)
          return Rdux::Result[ok: false, val: { errors: card.errors }, save: true, after_save: AFTER_SAVE]
        end

        token = PaymentGateway.tokenize(card)
        return Rdux::Result[false, { errors: { base: 'Invalid credit card' } }] unless token

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
          Rdux::Result[true, { credit_card_id: card.id }, { credit_card: card }]
        else
          Rdux::Result[false, { errors: card.errors }]
        end
      end
    end
  end
end
