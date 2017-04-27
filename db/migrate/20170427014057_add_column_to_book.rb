class AddColumnToBook < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :image_uri, :string
    add_column :books, :url, :string
  end
end
