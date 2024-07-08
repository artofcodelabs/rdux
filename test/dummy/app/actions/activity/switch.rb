# frozen_string_literal: true

class Activity
  module Switch
    def self.up(payload, opts = {})
      user, task = Common::Fetch.call(payload, opts).values_at(:user, :task)
      return Rdux::Result[false] if task.nil?

      activity = user.activities.current
      stop_res = Rdux.perform(Activity::Stop, {}, { ars: { activity:, user: } }) if activity
      create_res = Rdux.perform(Activity::Create, {}, { ars: { user:, task: } })
      Rdux::Result[ok: true, nested: [stop_res, create_res].compact, val: create_res.val]
    end

    def self.down(_, opts)
      opts[:nested].reverse.map(&:down)
    end
  end
end
