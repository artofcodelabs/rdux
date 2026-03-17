# frozen_string_literal: true

require 'test_helper'

class ActionResultTest < TC
  include TestHelpers

  describe '.call' do
    it 'tracks related records and db changes in action result' do
      user = users(:zbig)
      res = create_task(user)
      task = res.val[:task]
      result = res.action.result
      task_changes = result.dig('db_changes', "task##{task.id}")

      assert_equal task.id, result.dig('relations', "task##{task.id}")
      assert_equal [nil, task.id], task_changes['id']
      assert_equal [nil, task.name], task_changes['name']
      assert_equal [nil, user.id], task_changes['user_id']
      assert task_changes.key?('created_at')
      assert task_changes.key?('updated_at')
      assert_nil result.dig('db_changes', "user##{user.id}")
    end

    it 'stores tracked relations for querying' do
      res = create_task(users(:zbig))
      task = res.val[:task]

      assert_equal(
        [['Task', task.id]],
        ActionResource.where(action_id: res.action.id).order(:resource_type, :resource_id).pluck(:resource_type,
                                                                                                 :resource_id)
      )
    end
  end
end
