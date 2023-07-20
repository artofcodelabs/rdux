# frozen_string_literal: true

module Rdux
  module Actionable
    extend ActiveSupport::Concern

    included do
      if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
        serialize :up_payload, JSON
        serialize :up_result, JSON
        serialize :meta, JSON
      end

      validates :name, presence: true
      validates :up_payload, presence: true

      before_save do
        if meta_changed? && meta['stream'] && (meta_was || {})['stream'] != meta['stream']
          self.stream_hash = Digest::SHA256.hexdigest(meta['stream'].to_json)
        end
      end
    end

    class_methods do
      def table_name_prefix
        'rdux_'
      end
    end
  end
end
