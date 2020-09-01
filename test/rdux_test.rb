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
    end

    private

    def emit
      user = users(:zbig)
      Rdux.dispatch(:create_task, { user_id: user.id, task: { name: 'Foo bar baz' } }, { user: user })
    end
  end
end
