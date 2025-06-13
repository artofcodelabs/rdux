# frozen_string_literal: true

module Rdux
  Result = Struct.new(:ok, :val, :result, :save, :nested, :action) do
    def save_failed?
      ok == false && save
    end
  end
end
