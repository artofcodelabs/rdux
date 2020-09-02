# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ResultTest < TC
    describe '#payload' do
      it 'returns down_payload if resp is blank' do
        assert_equal({ foo: 'bar' }, Result.new(true, { foo: 'bar' }, nil).payload)
      end

      it 'returns resp if present' do
        assert_equal({ baz: 'buz' }, Result.new(true, { foo: 'bar' }, { baz: 'buz' }).payload)
      end
    end
  end
end
