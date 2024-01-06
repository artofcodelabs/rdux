# frozen_string_literal: true

module TestHelpers
  def create_task(user = users(:zbig), meta: {})
    opts = { ars: { user: } }
    Rdux.dispatch(Task::Create, TestData::Payloads.task, opts, meta:)
  end

  def create_activity(task_id: tasks(:homework).id, meta: {})
    Rdux.dispatch(Activity::Create, { task_id: }, meta:)
  end
end
