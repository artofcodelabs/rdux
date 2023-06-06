# frozen_string_literal: true

require 'rdux/engine'
require 'rdux/result'

module Rdux
  def self.dispatch(action_name, payload, opts = {})
    action = Action.new(name: action_name, up_payload: payload)
    res = action.call(opts)
    res = action.up(opts) if res.nil?
    action.down_payload = res.down_payload
    res.down_payload = action.down_payload
    action.save! if res.ok
    res.action = action
    res
  end
end
