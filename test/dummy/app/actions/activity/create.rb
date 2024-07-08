# frozen_string_literal: true

class Activity
  module Create
    def self.call(payload, opts = {})
      user, task = Common::Fetch.call(payload, opts).values_at(:user, :task)
      return Rdux::Result[false] if task.nil?

      activity = user.activities.create(task:)
      if activity.persisted?
        Rdux::Result[true, { activity: }]
      else
        Rdux::Result[false, { errors: activity.errors }]
      end
    end
  end
end
