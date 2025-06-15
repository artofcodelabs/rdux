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
      def call(payload, opts)
        user = opts[:user] || User.find(payload['user_id'])
        card = user.credit_cards.new(payload['credit_card'])
        res = validate_and_tokenize(card)
        return res if res.is_a?(Rdux::Result)

        card.token = res
        save_credit_card(card)
      end

      private

      def validate_and_tokenize(card)
        if card.invalid?(context: :before_request_gateway)
          return Rdux::Result[ok: false, val: { errors: card.errors }, save: true, after_save: AFTER_SAVE]
        end

        token = PaymentGateway.tokenize(card)
        token || Rdux::Result[ok: false, val: { errors: { base: 'Invalid credit card' } },
                              after_save: AFTER_SAVE]
      end

      def save_credit_card(card)
        if card.save
          Rdux::Result[true, { credit_card: card }]
        else
          Rdux::Result[false, { errors: card.errors }]
        end
      end
    end
  end
end
