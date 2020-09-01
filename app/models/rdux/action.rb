# frozen_string_literal: true

module Rdux
  class Action < ApplicationRecord
    def self.table_name_prefix
      'rdux_'
    end

    serialize :up_payload, JSON
    serialize :down_payload, JSON

    validates :name, presence: true
    validates :up_payload, presence: true

    def up(opts)
      if opts.any?
        action_creator.up(up_payload, opts)
      else
        action_creator.up(up_payload)
      end
    end

    def down
      action_creator.down(down_payload)
    end

    private

    def action_creator
      name.to_s.classify.constantize.new
    end
  end
end
