# frozen_string_literal: true

class Activity
  module Create
    def self.call(payload, opts = {})
      user = opts[:user] || User.find(payload['user_id'])
      task = opts[:task] || user.tasks.find_by(id: payload['task_id'])
      return Rdux::Result[false] if task&.user_id != user.id

      activity = user.activities.create(task:)
      if activity.persisted?
        Rdux::Result[true, { activity: }]
      else
        Rdux::Result[false, { errors: activity.errors }]
      end
    end
  end
end
