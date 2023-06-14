# frozen_string_literal: true

class CreateRduxActions < ActiveRecord::Migration[6.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name, null: false
      t.text :up_payload, null: false
      t.text :down_payload
      t.datetime :up_at, null: false
      t.datetime :down_at
      t.boolean :up_payload_sanitized, default: false

      t.timestamps
    end
  end
end
