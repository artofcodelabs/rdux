# frozen_string_literal: true

class Activity
  module Switch
    def self.up(payload, opts = {})
      user = opts[:user] || User.find(payload['user_id'])
      task = opts[:task] || user.tasks.find_by(id: payload['task_id'])
      return Rdux::Result[false] if task&.user_id != user.id

      activity = user.activities.current
      if activity
        stop_res = Rdux.perform(Activity::Stop, {}, { ars: { activity:, user: } })
      end
      create_res = Rdux.perform(Activity::Create, {}, { ars: { user:, task: } })
      Rdux::Result[ok: true, nested: [stop_res, create_res].compact, val: create_res.val]
    end

    def self.down(_, opts)
      opts[:nested].reverse.map(&:down)
    end
  end
end
