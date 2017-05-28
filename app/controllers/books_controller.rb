class BooksController < ApplicationController

  def index
    # 最も進んだステータスの登録日が古い順にソート
    @books = Book.find_by_sql( \
      ['select b.* from books b, statuses s1
        where b.user_id = ?
        and   b.id = s1.book_id
        and   s1.status_code = (
          select max(status_code) from statuses s2
          where s2.book_id = s1.book_id
          group by s2.book_id
        )
        order by s1.created_at;
        ', current_user.id])

    @books_status_0 = [] # 気になる
    @books_status_3 = [] # 購入済
    @books_status_7 = [] # 読書開始
    @books_status_9 = [] # 読了
    # 最も進んだステータスを取りに行く
    @books.each do |book|
      case book.get_max_status
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
    # jsでのエラー判別用
    @error_flg = 0

    if params[:title].present? || params[:author].present?
      # デバッグログ出力
      Amazon::Ecs.debug = true

      # 503エラーが理由なくしょっちゅう起きるためリトライする
      retry_count = 0

      begin
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
      rescue
        retry_count += 1
        if retry_count < 5
          sleep(1) # Amazonの設定上1秒待てばいいはずなので1秒だけ待つ
          retry
        else
          flash[:error] = "エラーが発生しました。しばらく置いてから再実行してください。"
          @error_flg = 1
        end
      end

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

      # 検索結果0件
      if @totalCount == 0
        flash[:danger] = "条件に該当する本がありません。"
        # 検索結果は返ってくるため、検索結果一覧を再描画するためエラーとしては扱わない
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def create
    logger.debug(params[:status])

    respond_to do |format|
      if Book.find_by(user_id: current_user.id, isbn: params[:isbn]).present?
        #登録済
        logger.debug("登録済")
        flash[:danger] = "本棚に登録済みです"
        format.js
      else
        book = Book.new(
          user_id: current_user.id,
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


  def status_update
    logger.debug(params[:book_id])

    status = Status.new(
      book_id: params[:book_id],
      status_code: params[:status])
    if status.save
      # 登録成功
    else
      # 登録失敗
    end
    flash[:success] = "更新しました。"
    # TODO 一旦リダイレクトで実装。最終的にはajax化する(一覧部分再描画)
    redirect_to books_path
  end

end
