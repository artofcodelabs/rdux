# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/store'
require 'rdux/result'
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
      res.result ||= opts[:result]
      assign(res, action)
      persist(res, action)
      res
    rescue StandardError => e
      handle_exception(e, action, opts[:result])
    end

    alias perform dispatch

    private

    def assign(res, action)
      action.ok = res.ok
      action.to_failed_action if res.save_failed?
      action.result = res.result
    end

    def persist(res, action)
      if res.ok || res.save_failed?
        res.action = action.tap(&:save!)
        res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
      else
        action.destroy
      end
    end

    def handle_exception(exc, action, result)
      action.to_failed_action
      action.result ||= result || {}
      action.result.merge!({ 'Exception' => {
                             class: exc.class.name,
                             message: exc.message
                           } })
      action.save!
      raise exc
    end
  end
end
