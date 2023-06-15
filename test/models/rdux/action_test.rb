# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ActionTest < TC
    TASK_PAYLOAD = { task: { 'name' => 'Foo bar baz' } }.freeze

    it 'serializes payload' do
      user = users(:zbig)
      up_payload = { user_id: user.id }.merge(TASK_PAYLOAD).stringify_keys
      assert_equal up_payload, perform_action(user).action.up_payload
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
        res = perform_action
        assert_nil res.action.down_at
        res.action.down
        assert_not_nil res.action.down_at
      end

      it 'prevents down if not the last action' do
        res = perform_action
        Rdux.dispatch(Activity::Create, { user_id: users(:zbig).id, task_id: res.payload[:id] })
        assert_equal false, Action.first.down
      end

      it 'prevents down if already down' do
        res = perform_action
        res.action.down
        assert_equal false, res.action.down
      end
    end

    private

    def perform_action(user = users(:zbig))
      Rdux.dispatch(Task::Create, { user_id: user.id }.merge(TASK_PAYLOAD))
    end
  end
end
