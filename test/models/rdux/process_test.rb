# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ProcessTest < TC
    it 'requires steps to be an array with at least one step' do
      process = Process.new(name: 'SomeProcess', steps: [])
      assert_equal false, process.valid?
      assert_includes process.errors[:steps], 'must include at least 1 step'

      process.steps = 'not-an-array'
      assert_equal false, process.valid?
      assert_includes process.errors[:steps], 'must be an Array'

      process.steps = ['Subscription::Preview']
      assert process.valid?
    end
  end
end
