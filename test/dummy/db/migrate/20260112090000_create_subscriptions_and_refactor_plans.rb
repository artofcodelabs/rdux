# frozen_string_literal: true

class CreateSubscriptionsAndRefactorPlans < ActiveRecord::Migration[7.0]
  def change
    # Turn `plans` into a plan catalog table (gold/premium)
    remove_column :plans, :ext_charge_id, :string
    remove_reference :plans, :user, foreign_key: true

    create_table :subscriptions do |t|
      t.string :ext_charge_id
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true

      t.timestamps
    end
  end
end
