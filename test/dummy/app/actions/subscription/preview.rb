# frozen_string_literal: true

class Subscription
  module Preview
    def self.call(payload) # rubocop:disable Metrics/MethodLength
      plan = Plan.find(payload['plan_id'])
      price_cents = plan.price_cents
      tax_rate = TaxGateway.rate_for(payload.dig('user', 'postal_code'))
      tax_cents = (price_cents * tax_rate).round

      Rdux::Result[
        ok: true,
        val: {
          price_cents:,
          tax_rate:,
          tax_cents:,
          total_cents: price_cents + tax_cents
        }
      ]
    end
  end
end
