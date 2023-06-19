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
    end
  end
end
