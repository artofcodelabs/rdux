# frozen_string_literal: true

class Task
  class Create
    def up(payload, opts = {})
      user = opts[:user] || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        Rdux::Result.new(true, { task_id: task.id }, { id: task.id })
      else
        Rdux::Result.new(false, { errors: task.errors })
      end
    end

    def down(payload)
      Delete.up(payload)
    end
  end
end
