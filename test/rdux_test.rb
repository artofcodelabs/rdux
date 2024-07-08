# frozen_string_literal: true

require 'test_helper'

module Rdux
  class Test < TC
    include TestHelpers

    describe '#dispatch' do
      it 'persists an action' do
        puts "#{ActiveRecord::Base.connection.adapter_name}: #{Action.columns_hash['up_payload'].type}"
        create_task
        assert_equal 1, Rdux::Action.count
      end

      it 'returns an action' do
        assert_instance_of Rdux::Action, create_task.action
      end

      it 'uses self.call unless up/down and does not store down_payload' do
        res = create_activity
        assert res.ok
        assert_equal users(:zbig).activities.last.id, res.val[:activity].id
        assert_nil res.down_payload
        assert_nil res.action.down_payload
      end

      it 'uses self.up/self.down and filters defined params' do
        res = Rdux.dispatch(CreditCard::Create, TestData::Payloads.credit_card_create(users(:zbig)))
        assert res.ok
        assert_equal '4242', res.val[:credit_card].last_four
        assert_equal '[FILTERED]', res.action.up_payload['credit_card']['number']
      end

      it 'assigns nested actions' do
        task = tasks(:homework)
        create_activity(task:)
        res = Rdux.dispatch(Activity::Switch, { task_id: create_task(task.user).val[:task].id, user_id: task.user_id })
        assert_equal 2, res.action.rdux_actions.count
      end

      it 'reverts nested actions' do
        task = tasks(:homework)
        create_activity(task:)
        res = Rdux.dispatch(Activity::Switch, { user_id: task.user_id, task_id: create_task(task.user).val[:task].id })
        res.action.down
        assert_equal 2, Rdux::Action.down.where(rdux_action_id: res.action.id).count
      end

      it 'sets meta' do
        user = users(:zbig)
        res = Rdux.dispatch(Activity::Switch, { user_id: user.id, task_id: create_task(user).val[:task].id },
                            meta: { foo: 'bar' })
        assert_equal({ 'foo' => 'bar' }, res.action.meta)
      end

      it 'sets up_result on action' do
        user = users(:zbig)
        res1 = Rdux.dispatch(Activity::Switch, { user_id: user.id, task_id: create_task(user).val[:task].id })
        res2 = Rdux.dispatch(Activity::Stop, { user_id: user.id, activity_id: res1.val[:activity].id })
        res2.action.up_result.tap do |up_result|
          assert_nil up_result['end_at'][0]
          assert_not_nil up_result['end_at'][1]
          assert up_result['updated_at'][0] < up_result['updated_at'][1]
        end
      end

      it 'can save failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:credit_card][:number] = '123'
        Rdux.dispatch(CreditCard::Create, payload, meta: { foo: 'bar', stream: 'baz' })
        assert_equal 1, Rdux::FailedAction.count
        assert_equal 0, Rdux::Action.count
        fa = Rdux::FailedAction.last
        assert_equal '[FILTERED]', fa.up_payload['credit_card']['number']
        assert_equal({ 'foo' => 'bar', 'stream' => 'baz' }, fa.meta)
      end

      it 'can save actions assigned to failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:amount] = 99.99
        Rdux.dispatch(CreditCard::Charge, payload)
        assert_equal 1, Rdux::FailedAction.count
        assert_equal 1, Rdux::Action.count
      end

      it 'can save both: actions and failed action assigned to failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:amount] = 99.99
        payload[:plan] = 'gold'
        res = Rdux.dispatch(Plan::Create, payload, { user: users(:zbig) })
        assert_equal 2, Rdux::FailedAction.count
        assert_equal 1, Rdux::Action.count
        assert_equal 'Plan::Create', res.action.name
        assert_equal ['CreditCard::Charge'], res.action.rdux_failed_actions.map(&:name)
        assert_equal ['CreditCard::Create'], res.action.rdux_failed_actions[0].rdux_actions.map(&:name)
      end

      it 'calls after_save callback' do
        res = create_task(meta: { inc: 1 })
        assert_equal 2, res.action.meta['inc']
      end

      it 'allows for recognizing failed actions caused by exception' do
        assert_raises(ActiveRecord::RecordNotFound) do
          Rdux.dispatch(Task::Create, { user_id: 0 })
        end
        assert_equal 0, Rdux::Action.count
        assert_equal 1, Rdux::FailedAction.count
        up_result = { 'Exception' => { 'class' => 'ActiveRecord::RecordNotFound',
                                       'message' => "Couldn't find User with 'id'=0" } }
        assert_equal up_result, Rdux::FailedAction.last.up_result
      end
    end
  end
end
