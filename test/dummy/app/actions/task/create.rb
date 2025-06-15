# frozen_string_literal: true

class Task
  class Create
    AFTER_SAVE = lambda { |action|
      if action.meta['inc']
        action.meta['inc'] += 1
        action.save!
      end
    }

    def call(payload, opts)
      user = opts.dig(:ars, :user) || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        opts[:result] = { task_id: task.id }
        Rdux::Result[ok: true, val: { task: }, after_save: AFTER_SAVE]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end
  end
end
