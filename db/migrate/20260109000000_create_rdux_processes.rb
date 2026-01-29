# frozen_string_literal: true

class CreateRduxProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_processes do |t|
      t.string :name
      t.boolean :ok
      t.column :steps, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text),
               null: false,
               default: (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? [] : '[]')
      t.column :payload, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text), null: false
      t.boolean :payload_sanitized, default: false, null: false

      t.timestamps
    end
  end
end
