# frozen_string_literal: true

class Task
  module Delete
    def self.up(payload)
      task = Task.find(payload['task_id'])
      task.destroy
      Rdux::Result[true, { task: task.attributes }]
    end
  end
end
