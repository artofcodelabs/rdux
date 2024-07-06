# frozen_string_literal: true

class Activity
  module Common
    module Fetch
      def self.call(payload, opts = {})
        user = opts[:user] || (payload['user_id'] && User.find(payload['user_id']))
        task = opts[:task] || (payload['task_id'] && user.tasks.find_by(id: payload['task_id']))
        activity = opts[:activity] || (payload['activity_id'] && user.activities.find_by(id: payload['activity_id']))
        { user:, task:, activity: }
      end
    end
  end
end
