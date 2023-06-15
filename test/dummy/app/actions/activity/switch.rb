# frozen_string_literal: true

class Activity
  module Switch
    def self.up(payload, opts = {})
      task = opts[:task] || Task.find(payload['task_id'])
      current_activity = task.user.activities.current
      if current_activity
        Rdux.dispatch(Activity::Stop, { activity_id: current_activity.id }, { activity: current_activity })
      end
      res = Rdux.dispatch(Activity::Create, { task_id: task.id }, { task: })
      Rdux::Result.new(true, res.payload)
    end

    def self.down(payload); end
  end
end
