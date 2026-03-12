# frozen_string_literal: true

class CreateRduxActions < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name, null: false
      t.column :payload, json_column_type, null: false
      t.boolean :payload_sanitized, default: false, null: false
      t.column :result, json_column_type
      t.column :meta, json_column_type
      t.column :ok, :boolean

      t.belongs_to :rdux_action, index: true, foreign_key: true

      t.timestamps
    end
  end

  private

  def json_column_type
    connection.adapter_name == 'PostgreSQL' ? :jsonb : :text
  end
end
