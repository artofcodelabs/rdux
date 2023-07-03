# frozen_string_literal: true

require 'test_helper'

module Rdux
  class Test < TC
    include TestHelpers

    describe '#dispatch' do
      it 'persists an action' do
        create_task
        assert_equal 1, Rdux::Action.count
      end

      it 'returns an action' do
        assert_instance_of Rdux::Action, create_task.action
      end

      it 'uses self.call unless up/down and does not store down_payload' do
        res = create_activity
        assert res.ok
        assert_equal users(:zbig).activities.last.id, res.payload['activity'].id
        assert_nil res.down_payload
        assert_nil res.action.down_payload
      end

      it 'uses self.up/self.down and filters defined params' do
        res = Rdux.dispatch(CreditCard::Create, TestData::ACTIONS['CreditCard::Create'].call(users(:zbig)))
        assert res.ok
        assert_equal '4242', res.payload[:credit_card].last_four
        assert_equal '[FILTERED]', res.action.up_payload['credit_card']['number']
      end

      it 'assigns nested actions' do
        create_activity
        res = Rdux.dispatch(Activity::Switch, { task_id: create_task.payload[:id] })
        assert_equal 2, res.action.rdux_actions.count
      end

      it 'reverts nested actions' do
        create_activity
        res = Rdux.dispatch(Activity::Switch, { task_id: create_task.payload[:id] })
        res.action.down
        assert_equal 2, Rdux::Action.down.where(rdux_action_id: res.action.id).count
      end

      it 'sets meta' do
        res = Rdux.dispatch(Activity::Switch, { task_id: create_task.payload[:id] }, meta: { foo: 'bar' })
        assert_equal({ 'foo' => 'bar' }, res.action.meta)
      end

      it 'sets up_result on action' do
        res1 = Rdux.dispatch(Activity::Switch, { task_id: create_task.payload[:id] })
        res2 = Rdux.dispatch(Activity::Stop, { activity_id: res1.payload['activity'].id })
        res2.action.up_result.tap do |up_result|
          assert_nil up_result['end_at'][0]
          assert_not_nil up_result['end_at'][1]
          assert up_result['updated_at'][0] < up_result['updated_at'][1]
        end
      end

      it 'can save failed action' do
        payload = TestData::ACTIONS['CreditCard::Create'].call(users(:zbig)).deep_dup
        payload[:credit_card][:number] = '123'
        Rdux.dispatch(CreditCard::Create, payload)
        assert_equal 1, Rdux::FailedAction.count
        assert_equal 0, Rdux::Action.count
        fa = Rdux::FailedAction.last
        assert_equal '[FILTERED]', fa.up_payload['credit_card']['number']
      end

      it 'can save actions assigned to failed action' do
        payload = TestData::ACTIONS['CreditCard::Create'].call(users(:zbig)).deep_dup
        payload[:amount] = 99.99
        Rdux.dispatch(CreditCard::Charge, payload)
        assert_equal 1, Rdux::FailedAction.count
        assert_equal 1, Rdux::Action.count
      end
    end
  end
end
