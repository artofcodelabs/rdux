# frozen_string_literal: true

module Rdux
  module Processing
    module_function

    def call_steps(process, payload)
      res = nil
      process.steps.each do |step|
        res = Rdux.perform(step, payload)
        res.action.process = process
        res.action.save!
        break unless res.ok
      end
      res
    end
  end
end
