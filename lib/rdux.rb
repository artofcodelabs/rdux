# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'

module Rdux
  class << self
    def dispatch(action_name, payload, opts = {})
      action = Action.new(name: action_name, up_payload: payload)
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
      res.down_payload.deep_stringify_keys!
      action.down_payload = res.down_payload
      assign_and_persist(res, action)
    end

    def assign_and_persist(res, action)
      if res.ok
        action.up_payload = filter_payload(action.up_payload)
        action.save!
      end
      res.action = action
      res
    end

    def filter_payload(payload)
      filtered_payload = payload.deep_dup # Create a duplicate to avoid modifying the original params
      Rails.application.config.filter_parameters.each do |filter_param|
        filter_recursive(filtered_payload, filter_param)
      end
      filtered_payload
    end

    def filter_recursive(payload, filter_param)
      payload.each do |key, value|
        if value.is_a? Hash # If the value is a nested parameter
          filter_recursive(value, filter_param)
        elsif key == filter_param.to_s # to_s is used to ensure that symbol/string difference does not matter
          payload[key] = '[FILTERED]'
        end
      end
    end
  end
end
