# frozen_string_literal: true

module Rdux
  Result = Struct.new(:ok, :down_payload, :resp, :action, :up_result, :nested, :save) do
    def payload
      resp || down_payload
    end
    alias_method :val, :payload

    def save_failed?
      ok == false && save
    end
  end
end
