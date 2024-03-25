# frozen_string_literal: true

module Rdux
  Result = Struct.new(:ok, :down_payload, :val, :up_result, :save, :after_save, :nested, :action) do
    def val
      self[:val] || down_payload
    end

    def save_failed?
      ok == false && save
    end
  end
end
