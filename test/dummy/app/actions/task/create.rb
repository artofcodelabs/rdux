# frozen_string_literal: true

class Task
  module Create
    class << self
      def call(payload, opts)
        task = init_task(payload, opts.dig(:ars, :user))
        if task.save
          process_action(opts[:action], task)
          Rdux::Result[ok: true, val: { task: }]
        else
          Rdux::Result[false, { errors: task.errors }]
        end
      end

      private

      def init_task(payload, user)
        user ||= User.find(payload['user_id'])
        user.tasks.new(payload['task'])
      end

      def process_action(action, task)
        action.result = ActionResult.call(
          action:,
          resources: [task]
        )
        action.meta['inc'] += 1 if action.meta['inc']
      end
    end
  end
end
