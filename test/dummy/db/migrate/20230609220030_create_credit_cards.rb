# frozen_string_literal: true

class CreateCreditCards < ActiveRecord::Migration[7.0]
  def change
    create_table :credit_cards do |t|
      t.string :first_name
      t.string :last_name
      t.string :last_four
      t.integer :expiration_month
      t.integer :expiration_year
      t.string :token
      t.belongs_to :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
