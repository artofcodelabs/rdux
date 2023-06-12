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
      action.save! if res.ok
      res.action = action
      res
    end
  end
end
