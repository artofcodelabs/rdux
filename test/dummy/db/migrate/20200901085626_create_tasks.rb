# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :name
      t.belongs_to :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
