# frozen_string_literal: true

module CreateActivity
  def self.call(payload)
    user = User.find(payload['user_id'])
    task = user.tasks.find(payload['task_id'])
    activity = user.activities.new(task: task)
    if activity.save
      Rdux::Result.new(true, { activity_id: activity.id })
    else
      Rdux::Result.new(false, { errors: activity.errors })
    end
  end
end
