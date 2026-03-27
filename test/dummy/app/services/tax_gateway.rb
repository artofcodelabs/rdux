# frozen_string_literal: true

module TaxGateway
  def self.rate_for(postal_code)
    return 0.0 if postal_code.nil?

    pc = postal_code.to_s.strip.upcase
    case pc[0]
    when '9' then 0.0975
    when '1', '2' then 0.08
    else 0.05
    end
  end
end
