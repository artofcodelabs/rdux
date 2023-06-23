# frozen_string_literal: true

module Rdux
  class Action < ApplicationRecord
    include Actionable

    serialize :down_payload, JSON

    scope :up, -> { where(down_at: nil) }
    scope :down, -> { where.not(down_at: nil) }

    def call(opts = {})
      perform_action(:call, up_payload, opts)
    end

    def up(opts = {})
      return false if up_payload_sanitized
      return false unless down_at.nil?

      perform_action(:up, up_payload, opts)
    end

    def down
      return false unless down_at.nil?
      return false if self.class.where('created_at > ?', created_at)
                          .where(down_at: nil)
                          .where('id != ?', rdux_action_id.to_i)
                          .count.positive?

      perform_action(:down, down_payload, build_opts)
      update(down_at: Time.current)
    end

    def to_failed_action
      FailedAction.new(attributes.except('down_payload', 'down_at'))
    end

    private

    def action_creator(meth)
      name_const = name.to_s.classify.constantize
      return name_const if name_const.respond_to?(meth)
      return unless name_const.is_a?(Class)

      obj = name_const.new
      obj.respond_to?(meth) ? obj : nil
    end

    def perform_action(meth, payload, opts)
      responder = action_creator(meth)
      return if responder.nil?

      if opts.any?
        responder.public_send(meth, payload, opts)
      else
        responder.public_send(meth, payload)
      end
    end

    def build_opts
      {}.tap do |h|
        nested = rdux_actions.order(:created_at)
        h[:nested] = nested if nested.any?
      end
    end
  end
end
