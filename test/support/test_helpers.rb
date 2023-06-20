# frozen_string_literal: true

module TestHelpers
  def create_task(user = users(:zbig))
    Rdux.dispatch(Task::Create, { user_id: user.id }.merge(TestData::TASK_PAYLOAD))
  end

  def create_activity
    Rdux.dispatch(Activity::Create, { task_id: tasks(:homework).id })
  end
end
