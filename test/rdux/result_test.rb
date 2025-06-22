# frozen_string_literal: true

require 'test_helper'

module Rdux
  class ResultTest < TC
    describe '#save_failed?' do
      it 'returns false by default' do
        assert_equal false, Result[false].save_failed?
      end

      it 'returns true if save is true' do
        assert_equal true, Result[ok: false, save: true].save_failed?
      end
    end
  end
end
