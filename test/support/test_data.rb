# frozen_string_literal: true

module TestData
  VALID_CREDIT_CARD = {
    first_name: 'Zbig',
    last_name: 'Zbigowski',
    number: '4242424242424242',
    expiration_month: 5,
    expiration_year: Time.current.year + 1
  }.freeze

  module Payloads
    class << self
      def task
        { task: { 'name' => 'Foo bar baz' } }
      end

      def credit_card_create(user)
        { user_id: user.id, credit_card: VALID_CREDIT_CARD.deep_dup }
      end
    end
  end
end
