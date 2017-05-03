class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.integer :user_id
      t.string :isbn
      t.string :title
      t.string :author
      t.string :image_url
      t.string :url

      t.timestamps
    end
  end
end
