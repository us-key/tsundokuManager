class CreateStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :statuses do |t|
      t.integer :book_id
      t.integer :status_code

      t.timestamps
    end
  end
end
