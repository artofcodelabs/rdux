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

        first, second = res.val[:process].actions.order(:id).to_a
        assert_equal 'Subscription::Preview', first.name
        assert_equal %w[customer plan_id], first.payload.keys.sort
        assert_equal plans(:gold).id, first.payload['plan_id']
        assert_equal({ 'postal_code' => '94105' }, first.payload['customer'])

        assert_equal 'CreditCard::Create', second.name
        assert_equal %w[credit_card user_id], second.payload.keys.sort
        assert_equal users(:zbig).id, second.payload['user_id']
        assert_equal '[FILTERED]', second.payload['credit_card']['number']
      end
    end
  end
end
