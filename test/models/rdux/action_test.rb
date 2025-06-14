# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ActionTest < TC
    include TestHelpers

    it 'serializes payload' do
      user = users(:zbig)
      payload = { user_id: user.id }.merge(TestData::Payloads.task).deep_stringify_keys
      assert_equal payload, create_task(user).action.payload
    end

    describe '#up' do
      it 'prevents performing a stored action if sanitized payload' do
        skip 'implement after adding .store'
        Rdux.dispatch(CreditCard::Create, TestData::Payloads.credit_card_create(users(:zbig)))
      end

      it 'prevents performing an action again' do
        user = users(:zbig)
        res1 = Rdux.dispatch(Activity::Switch, { user_id: user.id, task_id: create_task(user).val[:task].id })
        res2 = Rdux.dispatch(Activity::Stop, { user_id: user.id, activity_id: res1.val[:activity].id })
        assert_equal false, res2.action.up
        assert_equal false, res1.action.up
      end
    end
  end
end
