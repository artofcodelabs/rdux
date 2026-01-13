# frozen_string_literal: true

require 'test_helper'

module Rdux
  class StartTest < TC
    include TestHelpers

    describe '#start' do
      it 'starts a process' do
        payload = {
          'plan_id' => plans(:gold).id,
          'customer' => { 'postal_code' => '94105' },
          'user_id' => users(:zbig).id, # TODO: remove
          'credit_card' => TestData::VALID_CREDIT_CARD
        }
        res = Rdux.start(Processes::Subscription::Create, payload)
        assert res.ok
        assert_equal 1, res.val[:process].id
        assert_equal ['Subscription::Preview', 'CreditCard::Create'], res.val[:process].steps
        assert_equal ['Subscription::Preview', 'CreditCard::Create'],
                     res.val[:process].actions.order(:id).pluck(:name)
      end
    end
  end
end
