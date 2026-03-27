# frozen_string_literal: true

# This migration comes from rdux (originally 20260109000001)
class AddRduxProcessToRduxActions < ActiveRecord::Migration[7.0]
  def change
    add_reference :rdux_actions, :rdux_process, index: true, foreign_key: { to_table: :rdux_processes }
  end
end
