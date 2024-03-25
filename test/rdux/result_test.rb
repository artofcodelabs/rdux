# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ResultTest < TC
    describe '#payload' do
      it 'returns down_payload if val is blank' do
        assert_equal({ foo: 'bar' }, Result.new(true, { foo: 'bar' }, nil).val)
      end

      it 'returns val if present' do
        assert_equal({ baz: 'buz' }, Result.new(true, { foo: 'bar' }, { baz: 'buz' }).val)
      end
    end
  end
end
