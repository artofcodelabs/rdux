# frozen_string_literal: true

require 'rdux/engine'

require 'rdux/result'

module Rdux
  module_function

  def dispatch(action_name, payload, opts = {})
    action = Action.new(name: action_name, up_payload: payload)
    res = action.up(opts)
    action.down_payload = res.down_payload
    res.down_payload = action.down_payload
    action.save! if res.ok
    res.action = action
    res
  end
end
