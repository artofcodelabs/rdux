# frozen_string_literal: true

module Rdux
  class Action < ApplicationRecord
    include Actionable

    attr_accessor :up_payload_unsanitized

    belongs_to :rdux_failed_action, optional: true, class_name: 'Rdux::FailedAction'
    belongs_to :rdux_action, optional: true, class_name: 'Rdux::Action'
    has_many :rdux_actions, class_name: 'Rdux::Action', foreign_key: 'rdux_action_id'

    serialize :down_payload, coder: JSON if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'

    scope :up, -> { where(down_at: nil) }
    scope :down, -> { where.not(down_at: nil) }

    def call(opts = {})
      perform_action(:call, up_payload_unsanitized || up_payload, opts)
    end

    def up(opts = {})
      return false if up_payload_sanitized && up_payload_unsanitized.nil?
      return false unless down_at.nil?

      perform_action(:up, up_payload_unsanitized || up_payload, opts)
    end

    def down
      return false unless down_at.nil?
      return false unless can_down?

      res = perform_action(:down, down_payload, build_opts)
      update(down_at: Time.current)
      res
    end

    def to_failed_action
      FailedAction.new(attributes.except('down_payload', 'down_at', 'rdux_action_id'))
    end

    private

    def can_down?
      q = self.class.where('created_at > ?', created_at)
              .where(down_at: nil)
              .where('rdux_action_id IS NULL OR rdux_action_id != ?', id)
      q = q.where(stream_hash:) unless stream_hash.nil?
      !q.count.positive?
    end

    def action_performer(meth)
      name_const = name.to_s.constantize
      return name_const if name_const.respond_to?(meth)
      return unless name_const.is_a?(Class)

      obj = name_const.new
      obj.respond_to?(meth) ? obj : nil
    end

    def perform_action(meth, payload, opts)
      performer = action_performer(meth)
      return if performer.nil?

      if opts.any? || performer.method(meth).arity.abs == 2
        performer.public_send(meth, payload, opts.merge!(action: self))
      else
        performer.public_send(meth, payload)
      end
    end

    def build_opts
      nested = rdux_actions.order(:created_at)
      {}.tap do |h|
        h[:nested] = nested if nested.any?
      end
    end
  end
end
