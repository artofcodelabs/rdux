# frozen_string_literal: true

class AddPriceCentsToPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :plans, :price_cents, :integer, null: false, default: 0
  end
end
