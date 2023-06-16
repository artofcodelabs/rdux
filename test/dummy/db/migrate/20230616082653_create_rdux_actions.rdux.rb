# frozen_string_literal: true

# This migration comes from rdux (originally 20200823045609)
class CreateRduxActions < ActiveRecord::Migration[6.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name, null: false
      t.text :up_payload, null: false
      t.text :down_payload
      t.datetime :up_at, null: false
      t.datetime :down_at
      t.boolean :up_payload_sanitized, default: false

      t.belongs_to :rdux_action, index: true, foreign_key: true

      t.timestamps
    end
  end
end
