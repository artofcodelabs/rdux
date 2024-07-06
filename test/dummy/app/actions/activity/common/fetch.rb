# frozen_string_literal: true

class Activity
  module Common
    module Fetch
      class << self
        def call(payload, opts = {})
          user = opts[:user] || (payload['user_id'] && User.find(payload['user_id']))
          task = fetch(:tasks, user, opts[:task], payload['task_id'])
          activity = fetch(:activities, user, opts[:activity], payload['activity_id'])
          { user:, task:, activity: }
        end

        private

        def fetch(assoc, user, record, record_id)
          record ||= record_id && user.public_send(assoc).find_by(id: record_id)
          record = nil if record&.user_id != user.id
          record
        end
      end
    end
  end
end
