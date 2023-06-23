# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'
require 'rdux/sanitize'
require 'active_support/concern'

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
        assign_and_persist_for_ok(res, action)
      elsif res.save_failed?
        assign_and_persist_for_failed(res, action)
      end
      res.action ||= action
      res
    end

    def assign_and_persist_common(res, action)
      sanitize(action)
      action.up_result = res.up_result
    end

    def assign_and_persist_for_ok(res, action)
      assign_and_persist_common(res, action)
      res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
      action.save!
    end

    def assign_and_persist_for_failed(res, action)
      assign_and_persist_common(res, action)
      action.up_result ||= res.resp
      res.action = action.to_failed_action.tap(&:save!)
    end

    def sanitize(action)
      up_payload_sanitized = Sanitize.call(action.up_payload)
      action.up_payload_sanitized = action.up_payload != up_payload_sanitized
      action.up_payload = up_payload_sanitized
    end
  end
end
