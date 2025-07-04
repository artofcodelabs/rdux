# frozen_string_literal: true

class Activity
  module Stop
    def self.call(payload, opts)
      activity = Common::Fetch.call(payload, opts)[:activity]
      return Rdux::Result[false] if activity.nil? || activity.end_at

      activity.end_at = Time.current
      activity.save!
      result = activity.previous_changes
      Rdux::Result[ok: true, val: { activity_id: opts[:action].payload['activity_id'] }, result:]
    end
  end
end
