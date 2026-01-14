# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/store'
require 'rdux/result'
require 'rdux/processing'
require 'active_support/concern'

module Rdux
  class << self
    def dispatch(name, payload, opts = {}, meta: nil)
      action = store(name, payload, ars: opts[:ars], meta:)
      process(action, opts)
    end

    def store(name, payload, ars: nil, meta: nil)
      (ars || {}).each { |k, v| payload["#{k}_id"] = v.id }
      Store.call(name, payload, meta)
    end

    def process(action, opts = {})
      res = action.call(opts)
      return res if destroy_action(res, action)

      assign_to_action(res, action)
      persist(res, action)
      res
    rescue StandardError => e
      handle_exception(e, action)
    end

    alias perform dispatch

    def start(process_performer, payload)
      payload = payload.deep_stringify_keys
      process = Process.create!(name: process_performer, steps: process_performer::STEPS)
      selector = Processing.payload_selector_for(process_performer)
      res = Processing.call_steps(process, payload, payload_selector: selector)
      process.update!(ok: res.ok)
      Result[ok: res.ok, val: { process: }]
    end

    private

    def destroy_action(res, action)
      return false if res.ok || res.save

      action.destroy
    end

    def assign_to_action(res, action)
      action.ok = res.ok
      return unless res.result

      action.result ||= {}
      action.result.merge!(res.result)
    end

    def persist(res, action)
      res.action = action.tap(&:save!)
      res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
    end

    def handle_exception(exc, action)
      action.ok = false
      action.result ||= {}
      action.result.merge!({ 'Exception' => {
                             class: exc.class.name,
                             message: exc.message
                           } })
      action.save!
      raise exc
    end
  end
end
