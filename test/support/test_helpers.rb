# frozen_string_literal: true

module TestHelpers
  def create_task(user = users(:zbig), meta: {})
    opts = { ars: { user: } }
    Rdux.dispatch(Task::Create, TestData::Payloads.task, opts, meta:)
  end

  def create_activity(task: tasks(:homework), meta: {})
    Rdux.dispatch(Activity::Create, { user_id: task.user_id, task_id: task.id }, meta:)
  end
end
