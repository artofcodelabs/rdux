# frozen_string_literal: true

require 'test_helper'

module Rudux
  class Test < TC
    describe '#dispatch' do
      it 'persists an action' do
        emit
        assert_equal 1, Rudux::Action.count
      end

      it 'returns an action' do
        assert_instance_of Rudux::Action, emit.action
      end
    end

    private

    def emit
      user = users(:zbig)
      Rudux.dispatch(:create_task, { user_id: user.id, task: { name: 'Foo bar baz' } }, { user: user })
    end
  end
end
