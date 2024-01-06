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
      task = opts[:ars][:user].tasks.new(payload['task'])
      if task.save
        Rdux::Result[ok: true, down_payload: { task_id: task.id }, resp: { id: task.id }, after_save: AFTER_SAVE]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end

    def down(payload)
      Delete.up(payload)
    end
  end
end
