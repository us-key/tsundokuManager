class Status < ApplicationRecord
  belongs_to :book
  belongs_to :user

  validates :status_code, :uniqueness => {:scope => [:book_id, :user_id]}
end
