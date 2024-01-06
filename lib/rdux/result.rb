# frozen_string_literal: true

module Rdux
  Result = Struct.new(:ok, :down_payload, :resp, :up_result, :save, :after_save, :nested, :action) do
    def payload
      resp || down_payload
    end
    alias_method :val, :payload

    def save_failed?
      ok == false && save
    end
  end
end
