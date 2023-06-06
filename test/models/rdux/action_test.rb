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

    describe '#down' do
      it 'sets down_at' do
        res = perform_action
        assert_nil res.action.down_at
        res.action.down
        assert_not_nil res.action.down_at
      end
    end

    private

    def perform_action(user = users(:zbig))
      Rdux.dispatch(CreateTask, { user_id: user.id }.merge(TASK_PAYLOAD))
    end
  end
end
