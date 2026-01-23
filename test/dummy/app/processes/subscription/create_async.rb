# frozen_string_literal: true

module Processes
  module Subscription
    module CreateAsync
      STEPS = [
        lambda { |payload|
          Rdux.perform(::Subscription::Preview, payload)
        }
      ].freeze
    end
  end
end
