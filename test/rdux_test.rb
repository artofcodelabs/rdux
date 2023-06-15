# frozen_string_literal: true

require 'test_helper'

module Rdux
  class Test < TC
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
        assert_equal users(:zbig).activities.last.id, res.payload['activity_id']
        assert_nil res.down_payload
        assert_nil res.action.down_payload
      end

      it 'uses self.up/self.down and filters defined params' do
        res = Rdux.dispatch(CreditCard::Create, TestData::ACTIONS['CreditCard::Create'].call(users(:zbig)))
        assert res.ok
        assert_equal '4242', CreditCard.find(res.payload[:id]).last_four
        assert_equal '[FILTERED]', res.action.up_payload['credit_card']['number']
      end
    end

    private

    def create_task
      user = users(:zbig)
      Rdux.dispatch(Task::Create, { user_id: user.id, task: { name: 'Foo bar baz' } }, { user: user })
    end

    def create_activity
      Rdux.dispatch(Activity::Create, { task_id: tasks(:homework).id })
    end
  end
end
