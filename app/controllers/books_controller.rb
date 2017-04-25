class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def display_search

  end
end
