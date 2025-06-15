# frozen_string_literal: true

class CreditCard
  class Create
    class << self
      def call(payload, opts)
        user = opts[:user] || User.find(payload['user_id'])
        card = user.credit_cards.new(payload['credit_card'])
        res = validate_and_tokenize(card)
        if res.is_a?(Rdux::Result)
          opts[:action].meta['inc'] += 10 if opts[:action].meta['inc']
          return res
        end

        card.token = res
        save_credit_card(card)
      end

      private

      def validate_and_tokenize(card)
        if card.invalid?(context: :before_request_gateway)
          return Rdux::Result[ok: false, val: { errors: card.errors }, save: true]
        end

        token = PaymentGateway.tokenize(card)
        token || Rdux::Result[ok: false, val: { errors: { base: 'Invalid credit card' } }]
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
