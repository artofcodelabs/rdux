# frozen_string_literal: true

module Rdux
  class Action < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    attr_accessor :payload_unsanitized

    belongs_to :rdux_action, optional: true, class_name: 'Rdux::Action'
    has_many :rdux_actions, class_name: 'Rdux::Action', foreign_key: 'rdux_action_id'

    if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
      serialize :payload, coder: JSON
      serialize :result, coder: JSON
      serialize :meta, coder: JSON
    end

    validates :name, presence: true
    validates :payload, presence: true

    scope :ok, ->(val = true) { where(ok: val) }
    scope :failed, -> { where(ok: false) }

    def call(opts = {})
      return false if performed?
      return false if payload_sanitized && payload_unsanitized.nil?

      perform_action(payload_unsanitized || payload, opts)
    end

    def to_failed_action
      self.ok = false
      self
    end

    private

    def performed?
      !ok.nil?
    end

    def action_performer
      meth = :call
      name_const = name.to_s.constantize
      return name_const if name_const.respond_to?(meth)
      return unless name_const.is_a?(Class)

      obj = name_const.new
      obj.respond_to?(meth) ? obj : nil
    end

    def perform_action(payload, opts)
      meth = :call
      performer = action_performer
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
