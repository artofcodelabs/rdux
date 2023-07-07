# frozen_string_literal: true

module TestHelpers
  def create_task(user = users(:zbig))
    Rdux.dispatch(Task::Create, TestData::Payloads.task, { ars: { user: user } })
  end

  def create_activity
    Rdux.dispatch(Activity::Create, { task_id: tasks(:homework).id })
  end
end
