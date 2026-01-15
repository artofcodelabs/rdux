# frozen_string_literal: true

module Rdux
  class Action < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    attr_accessor :payload_unsanitized

    belongs_to :rdux_action, optional: true, class_name: 'Rdux::Action'
    belongs_to :process, optional: true, class_name: 'Rdux::Process', foreign_key: 'rdux_process_id'
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

      opts.merge!(action: self)
      perform_action(opts)
    end

    private

    def performed?
      !ok.nil?
    end

    def action_performer
      name_const = name.to_s.constantize
      return name_const if name_const.respond_to?(:call)
      return unless name_const.is_a?(Class)

      obj = name_const.new # TODO: remove + document self.call only
      obj.respond_to?(:call) ? obj : nil
    end

    def perform_action(opts)
      performer = action_performer
      return if performer.nil?

      if performer.method(:call).arity.abs == 2
        performer.call(payload_unsanitized || payload, opts)
      else
        performer.call(payload_unsanitized || payload)
      end
    end
  end
end
