# frozen_string_literal: true

module Rdux
  class Action < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    include SafePayload

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
      return false if only_sanitized_payload?

      opts.merge!(action: self)
      perform_action(opts)
    end

    private

    def performed?
      !ok.nil?
    end

    def perform_action(opts)
      performer = name.to_s.constantize
      return if performer.nil?

      if performer.method(:call).arity.abs == 2
        performer.call(safe_payload, opts)
      else
        performer.call(safe_payload)
      end
    end
  end
end
