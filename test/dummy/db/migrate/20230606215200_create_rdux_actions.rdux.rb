# frozen_string_literal: true

# This migration comes from rdux (originally 20200823045609)
class CreateRduxActions < ActiveRecord::Migration[6.0]
  def change
    create_table :rdux_actions do |t|
      t.string :name
      t.text :up_payload
      t.text :down_payload
      t.datetime :up_at
      t.datetime :down_at

      t.timestamps
    end
  end
end
