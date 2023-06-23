# frozen_string_literal: true

# This migration comes from rdux (originally 20230621215717)
class CreateRduxFailedActions < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_failed_actions do |t|
      t.string :name, null: false
      t.text :up_payload, null: false
      t.boolean :up_payload_sanitized, default: false
      t.text :up_result
      t.text :meta

      t.belongs_to :rdux_action, index: true, foreign_key: true

      t.timestamps
    end
  end
end
