# frozen_string_literal: true

module Rdux
  module MigrationHelpers
    private

    def json_column_type
      connection.adapter_name == 'PostgreSQL' ? :jsonb : :json
    end

    def json_array_default
      []
    end
  end
end
