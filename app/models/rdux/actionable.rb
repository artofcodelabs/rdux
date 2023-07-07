# frozen_string_literal: true

module Rdux
  module Actionable
    extend ActiveSupport::Concern

    included do
      serialize :up_payload, JSON
      serialize :up_result, JSON
      serialize :meta, JSON

      validates :name, presence: true
      validates :up_payload, presence: true
    end

    class_methods do
      def table_name_prefix
        'rdux_'
      end
    end
  end
end
