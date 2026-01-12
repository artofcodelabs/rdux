# frozen_string_literal: true

require 'test_helper'

module Rdux
  class StartTest < TC
    include TestHelpers

    describe '#start' do
      it 'starts a process' do
        res = Rdux.start(Processes::Subscription::Create)
        assert res.ok
        assert_equal 1, res.val[:process].id
        assert_equal ['Subscription::Preview', 'CreditCard::Create'], res.val[:process].steps
      end
    end
  end
end
