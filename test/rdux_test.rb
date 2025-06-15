# frozen_string_literal: true

require 'test_helper'

module Rdux
  class Test < TC
    include TestHelpers

    describe '#dispatch' do
      it 'persists an action' do
        puts "#{ActiveRecord::Base.connection.adapter_name}: #{Action.columns_hash['payload'].type}"
        create_task
        assert_equal 1, Rdux::Action.count
      end

      it 'returns an action' do
        assert_instance_of Rdux::Action, create_task.action
      end

      it 'uses self.call unless up' do
        res = create_activity
        assert res.ok
        assert_equal users(:zbig).activities.last.id, res.val[:activity].id
      end

      it 'uses self.up/self.down and filters defined params' do
        res = Rdux.dispatch(CreditCard::Create, TestData::Payloads.credit_card_create(users(:zbig)))
        assert res.ok
        assert_equal '4242', res.val[:credit_card].last_four
        assert_equal '[FILTERED]', res.action.payload['credit_card']['number']
      end

      it 'assigns nested actions' do
        task = tasks(:homework)
        create_activity(task:)
        res = Rdux.dispatch(Activity::Switch, { task_id: create_task(task.user).val[:task].id, user_id: task.user_id })
        assert_equal 2, res.action.rdux_actions.count
      end

      it 'sets meta' do
        user = users(:zbig)
        res = Rdux.dispatch(Activity::Switch, { user_id: user.id, task_id: create_task(user).val[:task].id },
                            meta: { foo: 'bar' })
        assert_equal({ 'foo' => 'bar' }, res.action.meta)
      end

      it 'sets result on action' do
        user = users(:zbig)
        res1 = Rdux.dispatch(Activity::Switch, { user_id: user.id, task_id: create_task(user).val[:task].id })
        res2 = Rdux.dispatch(Activity::Stop, { user_id: user.id, activity_id: res1.val[:activity].id })
        res2.action.result.tap do |result|
          assert_nil result['end_at'][0]
          assert_not_nil result['end_at'][1]
          assert result['updated_at'][0] < result['updated_at'][1]
        end
      end

      it 'can save failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:credit_card][:number] = '123'
        Rdux.dispatch(CreditCard::Create, payload, meta: { foo: 'bar', stream: 'baz' })
        assert_equal 1, Rdux::Action.failed.count
        assert_equal 0, Rdux::Action.ok.count
        fa = Rdux::Action.ok(false).last
        assert_equal '[FILTERED]', fa.payload['credit_card']['number']
        assert_equal({ 'foo' => 'bar', 'stream' => 'baz' }, fa.meta)
      end

      it 'can save actions assigned to failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:amount] = 99.99
        Rdux.dispatch(CreditCard::Charge, payload)
        assert_equal 1, Rdux::Action.ok(false).count
        assert_equal 1, Rdux::Action.ok.count
      end

      it 'saves result set via opts if exeption is raised' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:amount] = -99.99
        assert_raises(RuntimeError) do
          Rdux.dispatch(CreditCard::Charge, payload)
        end
        result = {
          'credit_card_create_action_id' => Rdux::Action.last.id,
          'Exception' => { 'class' => 'RuntimeError', 'message' => 'Negative amount' }
        }
        assert_equal(result, Rdux::Action.failed.last.result)
      end

      it 'can save both: actions and failed action assigned to failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:amount] = 99.99
        payload[:plan] = 'gold'
        res = Rdux.dispatch(Plan::Create, payload, { user: users(:zbig) })
        assert_equal 2, Rdux::Action.ok(false).count
        assert_equal 1, Rdux::Action.ok.count
        assert_equal 'Plan::Create', res.action.name
        assert_equal ['CreditCard::Charge'], res.action.rdux_actions.failed.map(&:name)
        assert_equal ['CreditCard::Create'], res.action.rdux_actions.failed[0].rdux_actions.map(&:name)
      end

      it 'calls after_save callback' do
        res = create_task(meta: { inc: 1 })
        assert_equal 2, res.action.meta['inc']
      end

      it 'calls after_save callback for failed action' do
        payload = { user_id: users(:zbig).id, credit_card: {} }
        res = Rdux.perform(CreditCard::Create, payload, meta: { inc: 11 })
        assert_equal 21, res.action.meta['inc']
      end

      it 'does not call after_save callback if no failed action' do
        payload = TestData::Payloads.credit_card_create(users(:zbig))
        payload[:credit_card][:number] = '1234'
        assert_nothing_raised do
          Rdux.dispatch(CreditCard::Create, payload, meta: { foo: 'bar', stream: 'baz' })
        end
      end

      it 'allows for recognizing failed actions caused by exception' do
        assert_raises(ActiveRecord::RecordNotFound) do
          Rdux.dispatch(Task::Create, { user_id: 0 })
        end
        assert_equal 0, Rdux::Action.ok.count
        assert_equal 1, Rdux::Action.failed.count
        result = { 'Exception' => { 'class' => 'ActiveRecord::RecordNotFound',
                                    'message' => "Couldn't find User with 'id'=0" } }
        assert_equal result, Rdux::Action.failed.last.result
      end

      it 'sets result via opts[:result]' do
        res = create_task
        assert_equal({ task_id: res.val[:task].id }, res.result)
        assert_equal({ 'task_id' => res.val[:task].id }, res.action.result)
      end
    end
  end
end
