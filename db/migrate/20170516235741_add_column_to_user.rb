class AddColumnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :alert_days_status_0, :integer
    add_column :users, :alert_days_status_3, :integer
    add_column :users, :alert_days_status_7, :integer
    add_column :users, :alert_days_status_9, :integer
  end
end
