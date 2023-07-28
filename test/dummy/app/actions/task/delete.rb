# frozen_string_literal: true

class Task
  module Delete
    def self.up(payload, opts = {})
      task = opts[:task] || Task.find(payload['task_id'])
      return Rdux::Result.new(false, { errors: ['Task not found'] }) if task.nil?

      task.destroy
      Rdux::Result.new(true, { task: task.attributes })
    end
  end
end
