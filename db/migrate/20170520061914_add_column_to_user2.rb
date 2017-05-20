class AddColumnToUser2 < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_alerted, :datetime
  end
end
