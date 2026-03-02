# frozen_string_literal: true

module Rdux
  module Dispatching
    def dispatch(name, payload, opts_arg = {}, opts: nil, meta: nil, process: nil) # rubocop:disable Metrics/ParameterLists
      opts ||= opts_arg
      opts[:process] ||= process
      action = store(name, payload, ars: opts.delete(:ars), meta:, process: opts[:process])
      process(action, opts)
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
      action.process.resume(res)&.tap { return _1 } if action.rdux_process_id && action.ok

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

    def handle_exception(exc, action)
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
