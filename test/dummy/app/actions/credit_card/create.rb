# frozen_string_literal: true

class CreditCard
  class Create
    Result = Struct.new(:ok, :val)

    class << self
      def call(payload, opts)
        card = init_card(payload, opts)

        res = valid_card?(card, opts[:action])
        return Rdux::Result[ok: false, val: res.val, save: true] unless res.ok

        res = tokenize(card, opts[:action])
        return Rdux::Result[ok: false, val: res.val] unless res.ok

        card.token = res.val
        save_credit_card(card)
      end

      private

      def init_card(payload, opts)
        user = opts[:user] || User.find(payload['user_id'])
        user.credit_cards.new(payload['credit_card'])
      end

      def update_meta(action)
        action.meta['inc'] += 10 if action.meta['inc']
      end

      def valid_card?(card, action)
        return Result[true] if card.valid?(context: :before_request_gateway)

        update_meta(action)
        Result[false, { errors: card.errors }]
      end

      def tokenize(card, action)
        token = PaymentGateway.tokenize(card)
        return Result[true, token] if token

        update_meta(action)
        Result[false, { errors: { base: 'Invalid credit card' } }]
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
