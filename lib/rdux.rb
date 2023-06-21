# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'
require 'rdux/sanitize'

module Rdux
  class << self
    def dispatch(action_name, payload, opts = {}, meta: nil)
      action = Action.new(name: action_name, up_payload: payload, meta: meta)
      call_call_meth_on_action(action, opts)
    end

    private

    def call_call_meth_on_action(action, opts)
      res = action.call(opts)
      return call_up_meth_on_action(action, opts) if res.nil?

      res.resp = res.down_payload.deep_stringify_keys
      res.down_payload = nil
      assign_and_persist(res, action)
    end

    def call_up_meth_on_action(action, opts)
      res = action.up(opts)
      res.down_payload&.deep_stringify_keys!
      action.down_payload = res.down_payload
      assign_and_persist(res, action)
    end

    def assign_and_persist(res, action)
      if res.ok
        up_payload_sanitized = Sanitize.call(action.up_payload)
        action.up_payload_sanitized = action.up_payload != up_payload_sanitized
        action.up_payload = up_payload_sanitized
        action.up_result = res.up_result
        res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
        action.save!
      end
      res.action = action
      res
    end
  end
end
