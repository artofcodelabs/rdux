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
          total_cents: 10_865
        }
      end

      it 'starts a process' do
        res = Rdux.start(Processes::Subscription::Create, subscription_create_payload)
        assert res.ok
        assert_equal 1, res.val[:process].id
        assert_equal ['Subscription::Preview', 'User::Create', 'CreditCard::Create', 'Payment::Create', 'Subscription::Create'],
                     res.val[:process].steps
        assert_equal ['Subscription::Preview', 'User::Create', 'CreditCard::Create', 'Payment::Create', 'Subscription::Create'],
                     res.val[:process].actions.order(:id).pluck(:name)
      end

      it 'starts a process asynchronously' do
        res = Rdux.start(Processes::Subscription::CreateAsync, subscription_create_payload)
        assert_nil res.val[:process].ok
      end

      it 'stores trimmed payload per step' do
        res = Rdux.start(Processes::Subscription::Create, subscription_create_payload)
        assert res.ok

        first, second, third = res.val[:process].actions.order(:id).to_a
        assert_equal 'Subscription::Preview', first.name
        assert_equal %w[plan_id total_cents user], first.payload.keys.sort
        assert_equal plans(:gold).id, first.payload['plan_id']
        assert_equal 10_865, first.payload['total_cents']
        assert_equal({ 'name' => 'John Doe', 'postal_code' => '94105' }, first.payload['user'])

        assert_equal 'User::Create', second.name
        assert_equal %w[user], second.payload.keys.sort
        assert_equal({ 'name' => 'John Doe', 'postal_code' => '94105' }, second.payload['user'])

        assert_equal 'CreditCard::Create', third.name
        assert_equal %w[credit_card user_id], third.payload.keys.sort
        assert_equal User.find_by(name: 'John Doe').id, third.payload['user_id']
        assert_equal '[FILTERED]', third.payload['credit_card']['number']
      end

      it 'fails when total_cents is invalid' do
        payload = subscription_create_payload.merge(total_cents: 10_864)

        res = Rdux.start(Processes::Subscription::Create, payload)
        assert_not res.ok

        process = res.val[:process].reload
        assert_equal false, process.ok

        actions = process.actions.order(:id).to_a
        assert_equal 1, actions.size
        assert_equal 'Subscription::Preview', actions.first.name
        assert_equal false, actions.first.ok
        assert_equal(
          ['must equal 10865 (got 10864)'],
          actions.first.result.dig('errors', 'total_cents')
        )
      end
    end
  end
end
