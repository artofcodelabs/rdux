# frozen_string_literal: true

class CreateRuduxActions < ActiveRecord::Migration[6.0]
  def change
    create_table :rudux_actions do |t|
      t.string :name
      t.text :up_payload
      t.text :down_payload

      t.timestamps
    end
  end
end
