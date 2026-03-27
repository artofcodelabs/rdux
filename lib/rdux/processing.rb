# frozen_string_literal: true

module Rdux
  module Processing
    def start(performer, payload)
      process = Process.new(name: performer, payload:)
      Sanitize.call(process)
      res = process.resume(Rdux::Result[ok: true, val: :start])
      process.update!(ok: res.ok) unless res.ok.nil?
      Result[ok: res.ok, val: { process: }]
    end
  end
end
