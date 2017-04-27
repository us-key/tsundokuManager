class Book < ApplicationRecord
  has_many :user_books
  has_many :users, through: :user_books
  has_many :statuses

  attr_accessor :title, :author, :image_url, :url

  def initialize(title, author, image_url, url)
    @title = title
    @author = author
    @image_url = image_url
    @url = url
  end
end
