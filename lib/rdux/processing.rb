# frozen_string_literal: true

module Rdux
  module Processing
    def start(process_performer, payload)
      payload = payload.deep_stringify_keys
      process = Process.create!(name: process_performer, steps: process_performer::STEPS)
      res = process.process_steps(payload:)
      process.update!(ok: res.ok) unless res.ok.nil?
      Result[ok: res.ok, val: { process: }]
    end
  end
end
