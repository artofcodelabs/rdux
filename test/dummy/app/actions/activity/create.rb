# frozen_string_literal: true

class Activity
  module Create
    def self.call(payload, opts = {})
      task = opts[:task] || Task.find(payload['task_id'])
      activity = task.user.activities.new(task:)
      if activity.save
        Rdux::Result[true, { activity: }]
      else
        Rdux::Result[false, { errors: activity.errors }]
      end
    end
  end
end
