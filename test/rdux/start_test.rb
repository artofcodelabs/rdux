# frozen_string_literal: true

require 'test_helper'

module Rdux
  class StartTest < TC
    include TestHelpers

    describe '#start' do
      def subscription_create_payload
        {
          plan_id: plans(:gold).id,
          user: { name: 'John Doe', postal_code: '94105' },
          credit_card: TestData::VALID_CREDIT_CARD,
          total_cents: 10_865 # TODO: implement
        }
      end

      it 'starts a process' do
        res = Rdux.start(Processes::Subscription::Create, subscription_create_payload)
        assert res.ok
        assert_equal 1, res.val[:process].id
        assert_equal ['Subscription::Preview', 'User::Create', 'CreditCard::Create'], res.val[:process].steps
        assert_equal ['Subscription::Preview', 'User::Create', 'CreditCard::Create'],
                     res.val[:process].actions.order(:id).pluck(:name)
      end

      it 'stores trimmed payload per step' do
        res = Rdux.start(Processes::Subscription::Create, subscription_create_payload)
        assert res.ok

        first, second, third = res.val[:process].actions.order(:id).to_a
        assert_equal 'Subscription::Preview', first.name
        assert_equal %w[plan_id user], first.payload.keys.sort
        assert_equal plans(:gold).id, first.payload['plan_id']
        assert_equal({ 'name' => 'John Doe', 'postal_code' => '94105' }, first.payload['user'])

        assert_equal 'User::Create', second.name
        assert_equal %w[user], second.payload.keys.sort
        assert_equal({ 'name' => 'John Doe', 'postal_code' => '94105' }, second.payload['user'])

        assert_equal 'CreditCard::Create', third.name
        assert_equal %w[credit_card user_id], third.payload.keys.sort
        assert_equal User.find_by(name: 'John Doe').id, third.payload['user_id']
        assert_equal '[FILTERED]', third.payload['credit_card']['number']
      end
    end
  end
end
