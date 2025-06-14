# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'
require 'active_support/concern'

module Rdux
  class << self
    def dispatch(action_name, payload, opts = {}, meta: nil)
      action = create_action(action_name, payload, opts, meta)
      res = call_call_or_up_on_action(action, opts)
      res.result ||= opts[:result]
      assign_and_persist(res, action)
      res.after_save.call(res.action) if res.after_save && res.action
      res
    end

    alias perform dispatch

    private

    def create_action(name, payload, opts, meta)
      (opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }
      action = Action.new(name:, payload:, meta:)
      sanitize(action)
      action.save!
      action
    end

    def call_call_or_up_on_action(action, opts)
      res = action.call(opts)
      return res if res

      action.up(opts)
    rescue StandardError => e
      handle_exception(e, action, opts[:result])
    end

    def assign_and_persist(res, action)
      action.ok = res.ok
      if res.ok
        assign_and_persist_for_ok(res, action)
      elsif res.save_failed?
        assign_and_persist_for_failed(res, action)
      else
        action.destroy
      end
    end

    def assign_and_persist_for_ok(res, action)
      action.result = res.result
      res.action = action.tap(&:save!) # TODO: don't save if no changes
      res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
    end

    def assign_and_persist_for_failed(res, action)
      action.result = res.result
      res.action = action.to_failed_action.tap(&:save!)
      assign_nested_responses_to_failed_action(res.action, res.nested) if res.nested
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
      param_filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
      payload_sanitized = param_filter.filter(action.payload)
      action.payload_sanitized = action.payload != payload_sanitized
      action.payload_unsanitized = action.payload if action.payload_sanitized
      action.payload = payload_sanitized
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
