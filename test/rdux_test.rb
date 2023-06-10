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

      it 'uses self.call unless up/down' do
        res = Rdux.dispatch(CreateActivity, { user_id: users(:zbig).id, task_id: tasks(:homework).id })
        assert res.ok
        assert_equal users(:zbig).activities.last.id, res.payload['activity_id']
      end

      it 'does not store down_payload if no down method' do
        skip 'TODO'
      end

      it 'uses self.up/self.down' do
        payload = {
          user_id: users(:zbig).id,
          credit_card: {
            first_name: 'Zbig',
            last_name: 'Zbigowski',
            number: '4242424242424242',
            expiration_month: 5,
            expiration_year: Time.current.year + 1
          }
        }
        res = Rdux.dispatch(CreditCard::Create, payload)
        assert res.ok
        assert_equal '**** **** **** 4242', CreditCard.find(res.payload[:id]).number
      end
    end

    private

    def emit
      user = users(:zbig)
      Rdux.dispatch(CreateTask, { user_id: user.id, task: { name: 'Foo bar baz' } }, { user: user })
    end
  end
end
