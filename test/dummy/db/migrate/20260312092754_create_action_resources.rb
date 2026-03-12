# frozen_string_literal: true

class CreateActionResources < ActiveRecord::Migration[8.0]
  def change
    create_table :action_resources do |t|
      t.references :action, null: false, index: false, foreign_key: { to_table: :rdux_actions }
      t.string :resource_type, null: false
      t.bigint :resource_id, null: false

      t.timestamps
    end

    add_index :action_resources, %i[action_id resource_type resource_id],
              unique: true, name: 'idx_action_resources_on_action_resource'
    add_index :action_resources, %i[resource_type resource_id], name: 'idx_action_resources_on_resource'
  end
end
