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
        assert_equal '4242', CreditCard.find(res.payload[:id]).last_four
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
    end
  end
end
