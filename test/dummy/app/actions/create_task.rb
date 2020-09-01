# frozen_string_literal: true

class CreateTask
  def up(payload, opts)
    user = opts[:user] || User.find(payload['user_id'])
    task = user.tasks.new(payload['task'])
    if task.save
      Rudux::Result.new(true, { task_id: task.id }, { id: task.id })
    else
      Rudux::Result.new(false, { errors: task.errors })
    end
  end

  def down(payload)
    Task.find(payload['task_id']).destroy
  end
end
