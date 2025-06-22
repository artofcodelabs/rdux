# frozen_string_literal: true

# This migration comes from rdux (originally 20230621215718)
class CreateRduxActions < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name, null: false
      t.column :payload, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text), null: false
      t.boolean :payload_sanitized, default: false, null: false
      t.column :result, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text)
      t.column :meta, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text)
      t.column :ok, :boolean

      t.belongs_to :rdux_action, index: true, foreign_key: true

      t.timestamps
    end
  end
end
