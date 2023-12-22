# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'
require 'rdux/sanitize'
require 'active_support/concern'

module Rdux
  class << self
    def dispatch(action_name, payload, opts = {}, meta: nil)
      (opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }
      action = Action.new(name: action_name, up_payload: payload, meta: meta)
      call_call_or_up_on_action(action, opts)
    end

    alias perform dispatch

    private

    def call_call_or_up_on_action(action, opts)
      res = action.call(opts)
      if res
        res.resp ||= res.down_payload
        res.down_payload = nil
      else
        res = action.up(opts)
      end
      assign_and_persist(res, action)
    end

    def assign_and_persist(res, action)
      action.down_payload = res.down_payload&.deep_stringify_keys!
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
      assign_nested_responses_to_failed_action(res.action, res.nested) unless res.nested.nil?
    end

    def assign_nested_responses_to_failed_action(failed_action, nested)
      nested.each do |nested_res|
        if nested_res.action.is_a?(Rdux::Action)
          failed_action.rdux_actions << nested_res.action
        else
          failed_action.rdux_failed_actions << nested_res.action
        end
      end
    end

    def sanitize(action)
      up_payload_sanitized = Sanitize.call(action.up_payload)
      action.up_payload_sanitized = action.up_payload != up_payload_sanitized
      action.up_payload = up_payload_sanitized
    end
  end
end
