# frozen_string_literal: true

class CreateRduxActions < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name, null: false
      t.column :up_payload, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text), null: false
      t.column :down_payload, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text)
      t.datetime :down_at
      t.boolean :up_payload_sanitized, default: false
      t.column :up_result, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text)
      t.column :meta, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text)

      t.belongs_to :rdux_action, index: true, foreign_key: true
      t.belongs_to :rdux_failed_action, index: true, foreign_key: true

      t.timestamps
    end
  end
end
