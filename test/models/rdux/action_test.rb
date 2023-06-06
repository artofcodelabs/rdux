# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ActionTest < TC
    it 'serializes payload' do
      payload = { name: 'Foo bar baz' }
      action = Action.create!(name: :create_task, up_payload: payload)

      assert_equal payload.stringify_keys, action.up_payload
    end
  end
end
