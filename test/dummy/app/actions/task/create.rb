# frozen_string_literal: true

class Task
  class Create
    AFTER_SAVE = lambda { |action|
      if action.meta['inc']
        action.meta['inc'] += 1
        action.save!
      end
    }

    def up(payload, opts = {})
      user = opts.dig(:ars, :user) || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        Rdux::Result[ok: true, down_payload: { user_id: user.id, task_id: task.id }, val: { task: }, after_save: AFTER_SAVE]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end

    def down(payload)
      Delete.up(payload)
    end
  end
end
