# frozen_string_literal: true

require 'rdux/engine'

module Rdux
  Result = Struct.new(:ok, :down_payload, :resp, :action) do
    def payload
      resp || down_payload
    end
  end

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
