# frozen_string_literal: true

class Task
  class Create
    def call(payload, opts)
      user = opts.dig(:ars, :user) || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        opts[:result] = { task_id: task.id }
        opts[:action].meta['inc'] += 1 if opts[:action].meta['inc']
        Rdux::Result[ok: true, val: { task: }]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end
  end
end
