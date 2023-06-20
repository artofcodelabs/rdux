# frozen_string_literal: true

class Activity
  module Create
    def self.call(payload, opts = {})
      task = opts[:task] || Task.find(payload['task_id'])
      activity = task.user.activities.new(task: task)
      if activity.save
        Rdux::Result.new(true, { activity: activity })
      else
        Rdux::Result.new(false, { errors: activity.errors })
      end
    end
  end
end
