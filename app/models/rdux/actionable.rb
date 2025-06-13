# frozen_string_literal: true

module Rdux
  module Actionable
    extend ActiveSupport::Concern

    included do
      if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
        serialize :payload, coder: JSON
        serialize :result, coder: JSON
        serialize :meta, coder: JSON
      end

      validates :name, presence: true
      validates :payload, presence: true
    end

    class_methods do
      def table_name_prefix
        'rdux_'
      end
    end
  end
end
