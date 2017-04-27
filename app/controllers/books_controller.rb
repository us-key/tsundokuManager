class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def display_search
  end

  def search
    if params[:title].present? || params[:author].present?
      # デバッグログ出力
      Amazon::Ecs.debug = true

      books = Amazon::Ecs.item_search(
        '', #keyword:titleとauthor個別で検索するためブランク
        title: params[:title],
        author: params[:author],
        search_index: 'Books',
        dataType: 'script',
        response_group: 'ItemAttributes, Images',
        country: 'jp',
        power: 'Not kindle'
      )

      @books = []
      books.items.each do |item|
        book = Book.new(
          item.get('ItemAttributes/Title'),
          item.get('ItemAttributes/Author'),
          item.get('LargeImage/URL'),
          item.get('DetailPageURL')
        )
        @books << book
      end
      @totalCount = books.total_results
    end
    respond_to do |format|
      format.js
    end
  end
end
