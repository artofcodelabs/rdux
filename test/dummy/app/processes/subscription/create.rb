# frozen_string_literal: true

module Processes
  module Subscription
    module Create
      STEPS = [
        ::Subscription::Preview,
        # Customer::Create,
        CreditCard::Create
        # Payment::Create,
        # Create,
        # Invoice::Create
      ].freeze
    end
  end
end
