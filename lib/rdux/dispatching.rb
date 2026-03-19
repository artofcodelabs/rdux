# frozen_string_literal: true

module Rdux
  module Dispatching
    def dispatch(name, payload, opts_arg = {}, opts: nil, meta: nil, process: nil) # rubocop:disable Metrics/ParameterLists
      opts ||= opts_arg
      action = store(name, payload, ars: opts.delete(:ars), meta:, process:)
      process(action, opts.merge(process:))
    end

    def store(name, payload, ars: nil, meta: nil, process: nil)
      (ars || {}).each { |k, v| payload["#{k}_id"] = v.id }
      Store.call(name:, payload:, meta:, process:)
    end

    def process(action, opts = {})
      res = action.call(opts)
      return res if destroy_action(res, action)

      assign_to_action(res, action)
      persist(res, action)
      resume_process(action, res)&.tap { return _1 }

      res
    rescue StandardError => e
      handle_exception(e, action)
    end

    alias perform dispatch

    private

    def destroy_action(res, action)
      return false if res.ok || res.save

      action.destroy
    end

    def assign_to_action(res, action)
      action.ok = res.ok
      return unless res.result

      action.result ||= {}
      action.result.merge!(res.result)
    end

    def persist(res, action)
      res.action = action.tap(&:save!)
      res.nested&.each { |nested_res| action.rdux_actions << nested_res.action }
    end

    def resume_process(action, res)
      return unless action.ok
      return unless action.has_attribute?(:rdux_process_id)
      return if action[:rdux_process_id].nil?

      action.process.resume(res)
    end

    def handle_exception(exc, action)
      raise(action.destroy && exc) if ENV['RDUX_DEV']

      action.ok = false
      action.result ||= {}
      action.result.merge!({ 'Exception' => {
                             class: exc.class.name,
                             message: exc.message
                           } })
      action.save!
      raise exc
    end
  end
end
