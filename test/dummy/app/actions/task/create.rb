# frozen_string_literal: true

class Task
  module Create
    class << self
      def call(payload, opts)
        task = init_task(payload, opts)
        if task.save
          opts[:action].result = { task_id: task.id }
          opts[:action].meta['inc'] += 1 if opts[:action].meta['inc']
          Rdux::Result[ok: true, val: { task: }]
        else
          Rdux::Result[false, { errors: task.errors }]
        end
      end

      private

      def init_task(payload, opts)
        user = opts.dig(:ars, :user) || User.find(payload['user_id'])
        user.tasks.new(payload['task'])
      end
    end
  end
end
