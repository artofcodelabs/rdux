# frozen_string_literal: true

class CreateRduxProcesses < ActiveRecord::Migration[7.0]
  include Rdux::MigrationHelpers

  def change
    create_table :rdux_processes do |t|
      t.string :name, null: false
      t.boolean :ok
      t.column :steps, json_column_type,
               null: false,
               default: []
      t.column :payload, json_column_type, null: false
      t.boolean :payload_sanitized, default: false, null: false

      t.timestamps
    end
  end
end
