class Status < ApplicationRecord
  belongs_to :book

  validates :status_code, :uniqueness => {:scope => :book_id}
end
