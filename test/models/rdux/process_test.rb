# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ProcessTest < TC
    module InvalidProcess
      ACTIONS = [].freeze
    end

    module SomeProcess
      ACTIONS = [
        { name: 'Subscription::Preview' },
        { name: 'User::Create' },
        { name: 'CreditCard::Create' },
        { name: 'Payment::Create' },
        { name: 'Subscription::Create' }
      ].freeze
    end

    it 'requires steps to be an array with at least one step' do
      process = Process.new(name: InvalidProcess, payload: { a: 1 })
      assert_equal false, process.valid?
      assert_includes process.errors[:steps], 'must include at least 1 step'

      process = Process.new(name: SomeProcess, payload: { a: 1 })
      assert process.valid?
    end
  end
end
