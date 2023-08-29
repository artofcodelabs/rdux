# frozen_string_literal: true

class Activity
  module Switch
    def self.up(payload, opts = {})
      task = opts[:task] || Task.find(payload['task_id'])
      current_activity = task.user.activities.current
      if current_activity
        stop_res = Rdux.perform(Activity::Stop, { activity_id: current_activity.id }, { activity: current_activity })
      end
      create_res = Rdux.perform(Activity::Create, { task_id: task.id })
      Rdux::Result[ok: true, nested: [stop_res, create_res].compact, resp: create_res.payload]
    end

    def self.down(_, opts)
      opts[:nested].reverse.map(&:down)
    end
  end
end
