# frozen_string_literal: true

# This migration comes from rdux (originally 20260109000000)
class CreateRduxProcesses < ActiveRecord::Migration[7.0]
  include Rdux::MigrationHelpers

  def change
    create_table :rdux_processes do |t|
      t.string :name
      t.boolean :ok
      t.column :steps, json_column_type,
               null: false,
               default: json_array_default
      t.column :payload, json_column_type, null: false
      t.boolean :payload_sanitized, default: false, null: false

      t.timestamps
    end
  end
end
