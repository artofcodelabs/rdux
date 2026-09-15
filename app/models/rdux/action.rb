# frozen_string_literal: true

module Rdux
  class Action < ActiveRecord::Base
    self.table_name_prefix = 'rdux_'

    include SafePayload

    belongs_to :rdux_action, optional: true, class_name: 'Rdux::Action'
    belongs_to :process, optional: true, class_name: 'Rdux::Process', foreign_key: 'rdux_process_id'
    has_many :rdux_actions, class_name: 'Rdux::Action', foreign_key: 'rdux_action_id'

    validates :name, presence: true
    validates :payload, presence: true

    scope :ok, ->(val = true) { where(ok: val) }
    scope :failed, -> { where(ok: false) }

    # has_attribute? keeps Rdux working when the rdux_process_id migration has not been run
    def process_defined?
      has_attribute?(:rdux_process_id) && rdux_process_id
    end

    def call(opts = {})
      return false if performed?
      return false if only_sanitized_payload?

      performer = name.to_s.constantize
      return performer.call(safe_payload) if performer.method(:call).arity == 1

      performer.call(safe_payload, opts.merge(action: self))
    end

    private

    def performed?
      !ok.nil?
    end
  end
end
