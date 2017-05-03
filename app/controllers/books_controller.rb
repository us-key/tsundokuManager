class BooksController < ApplicationController
  def index
    # 本来はログインユーザーで絞る
    @books = User.find(1).books
    @books_status_0 = [] # 気になる
    @books_status_3 = [] # 購入済
    @books_status_7 = [] # 読書開始
    @books_status_9 = [] # 読了
    # 最も進んだステータスを取りに行く
    @books.each do |book|
      max_status = book.statuses.order("status_code desc").limit(1)
      case max_status[0].status_code
      when 9 then
        @books_status_9 << book
      when 7 then
        @books_status_7 << book
      when 3 then
        @books_status_3 << book
      when 0 then
        @books_status_0 << book
      else
        # 何もしない
      end
    end
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
          isbn: item.get('ItemAttributes/ISBN'),
          title: item.get('ItemAttributes/Title'),
          author: item.get('ItemAttributes/Author'),
          image_url: item.get('LargeImage/URL'),
          url: item.get('DetailPageURL')
        )
        @books << book
      end
      @totalCount = books.total_results
    end

    respond_to do |format|
      format.js
    end
  end

  def create
    logger.debug(params[:status])
    # TODO 本来はログインユーザーを取得する
    user = User.find(1)

    respond_to do |format|
      if Book.find_by(user_id: user.id, isbn: params[:isbn]).present?
        #登録済
        logger.debug("登録済")
        flash[:danger] = "本棚に登録済みです"
        format.js
      else
        book = Book.new(
          user_id: user.id,
          isbn: params[:isbn],
          title: params[:title],
          author: params[:author],
          image_url: params[:image_url],
          url: params[:url]
        )

        if book.save
          # 登録成功
        else
          # 登録失敗
        end

        status = Status.new(
          book_id: book.id,
          status_code: params[:status]
        )
        if status.save
          # 登録成功
        else
          # 登録失敗
        end
        flash[:success] = "登録しました。"
        format.js
      end
    end
  end

end
