# frozen_string_literal: true

module TestData
  VALID_CREDIT_CARD = {
    first_name: 'Zbig',
    last_name: 'Zbigowski',
    number: '4242424242424242',
    expiration_month: 5,
    expiration_year: Time.current.year + 1
  }.freeze

  ACTIONS = {
    'CreditCard::Create' => lambda { |user|
      {
        user_id: user.id,
        credit_card: VALID_CREDIT_CARD
      }
    }
  }.freeze
end
