# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload, process|
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        User::Create
      ].freeze
    end
  end
end
