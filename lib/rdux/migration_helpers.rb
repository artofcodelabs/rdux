# frozen_string_literal: true

module Rdux
  module MigrationHelpers
    private

    def json_column_type
      connection.adapter_name == 'PostgreSQL' ? :jsonb : :json
    end
  end
end
