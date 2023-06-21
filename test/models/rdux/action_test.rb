# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ActionTest < TC
    include TestHelpers

    it 'serializes payload' do
      user = users(:zbig)
      up_payload = { user_id: user.id }.merge(TestData::TASK_PAYLOAD).stringify_keys
      assert_equal up_payload, create_task(user).action.up_payload
    end

    describe '#up' do
      it 'prevents going up again if sanitized payload' do
        res = Rdux.dispatch(CreditCard::Create, TestData::ACTIONS['CreditCard::Create'].call(users(:zbig)))
        res.action.down
        assert_equal false, res.action.up
      end

      it 'prevents going up again in general' do
        res1 = Rdux.dispatch(Activity::Switch, { task_id: create_task.payload[:id] })
        res2 = Rdux.dispatch(Activity::Stop, { activity_id: res1.payload['activity'].id })
        assert_equal false, res1.action.down
        assert res2.action.down
        assert res1.action.down
        assert_equal false, res2.action.up
        assert_equal false, res1.action.up
      end
    end

    describe '#down' do
      it 'sets down_at' do
        res = create_task
        assert_nil res.action.down_at
        res.action.down
        assert_not_nil res.action.down_at
      end

      it 'prevents down if not the last action' do
        res = create_task
        Rdux.dispatch(Activity::Create, { user_id: users(:zbig).id, task_id: res.payload[:id] })
        assert_equal false, Action.first.down
      end

      it 'prevents down if already down' do
        res = create_task
        res.action.down
        assert_equal false, res.action.down
      end

      it 'allows for reusing other action creators' do
        res = create_task
        res.action.down
        assert_equal 1, Action.count
        assert_equal 1, Task.count  # fixtures
      end
    end
  end
end
