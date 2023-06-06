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
    validates :up_at, presence: true

    before_validation do
      self.up_at = Time.current if new_record?
    end

    def call(opts)
      perform_action(:call, opts)
    end

    def up(opts)
      perform_action(:up, opts)
    end

    def down
      perform_action(:down, opts)
    end

    private

    def action_creator(meth)
      name_const = name.to_s.classify.constantize
      return name_const if name_const.respond_to?(meth)

      obj = name_const.new
      obj.respond_to?(meth) ? obj : nil
    end

    def perform_action(meth, opts)
      responder = action_creator(meth)
      return if responder.nil?

      if opts.any?
        responder.public_send(meth, up_payload, opts)
      else
        responder.public_send(meth, up_payload)
      end
    end
  end
end
