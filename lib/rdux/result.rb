# frozen_string_literal: true

module Rdux
  Result = Struct.new(:ok, :down_payload, :resp, :action, :nested) do
    def payload
      resp || down_payload
    end
  end
end
