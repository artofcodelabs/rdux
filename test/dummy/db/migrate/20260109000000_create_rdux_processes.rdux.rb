# frozen_string_literal: true

# This migration comes from rdux (originally 20260109000000)
class CreateRduxProcesses < ActiveRecord::Migration[7.0]
  def change
    create_table :rdux_processes do |t|
      t.string :name
      t.boolean :ok
      t.column :steps, (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? :jsonb : :text),
               null: false,
               default: (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? [] : '[]')

      t.timestamps
    end
  end
end
