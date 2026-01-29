# frozen_string_literal: true

module Rdux
  module Processing
    def start(process_performer, payload)
      process = Process.create!(name: process_performer, steps: process_performer::STEPS, payload:)
      res = process.process_steps
      process.update!(ok: res.ok) unless res.ok.nil?
      Result[ok: res.ok, val: { process: }]
    end
  end
end
