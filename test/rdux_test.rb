# frozen_string_literal: true

require 'test_helper'

module Rdux
  class Test < TC
    describe '#dispatch' do
      it 'persists an action' do
        emit
        assert_equal 1, Rdux::Action.count
      end

      it 'returns an action' do
        assert_instance_of Rdux::Action, emit.action
      end

      it 'uses up/down or call' do
        Rdux.dispatch(CreateActivity, { user_id: users(:zbig).id, task_id: tasks(:homework).id })
      end
    end

    private

    def emit
      user = users(:zbig)
      Rdux.dispatch(CreateTask, { user_id: user.id, task: { name: 'Foo bar baz' } }, { user: user })
    end
  end
end
