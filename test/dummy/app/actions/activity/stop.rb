# frozen_string_literal: true

class Activity
  module Stop
    def self.up(payload, opts = {})
      activity = opts[:activity] || Activity.find(payload['activity_id'])
      return Rdux::Result.new(false) unless activity.end_at.nil?

      activity.end_at = Time.current
      activity.save!
      Rdux::Result.new(true, { activity_id: activity.id })
    end

    def self.down(payload)
      activity = Activity.find(payload['activity_id'])
      activity.end_at = nil
      activity.save!
    end
  end
end
