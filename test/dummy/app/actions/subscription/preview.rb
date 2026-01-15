# frozen_string_literal: true

class Subscription
  module Preview
    def self.call(payload) # rubocop:disable Metrics/MethodLength
      plan = Plan.find(payload['plan_id'])
      price_cents = plan.price_cents
      tax_rate = TaxGateway.rate_for(payload.dig('user', 'postal_code'))
      tax_cents = (price_cents * tax_rate).round
      total_cents = price_cents + tax_cents

      if payload.key?('total_cents') && payload['total_cents'] != total_cents
        errors = {
          total_cents: ["must equal #{total_cents} (got #{payload['total_cents']})"]
        }
        return Rdux::Result[ok: false, val: { errors: }, result: { errors: }, save: true]
      end

      Rdux::Result[
        ok: true,
        val: { total_cents: },
        result: { total_cents: }
      ]
    end
  end
end
