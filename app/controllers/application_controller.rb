class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_action
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :discard_flash_if_xhr


  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end

    def discard_flash_if_xhr
      flash.discard if request.xhr?
    end

  private
    # 各メソッドの前に実行するアクション
    # deviseの認証確認し、OKならアラートのチェックを行う
    # (最後にアラートを挙げてから24時間以上経過していたら再度アラートを挙げる)
    def authenticate_action

      authenticate_user!

      books = current_user.books
      flash_message = ""
      # 最後にアラートを挙げてから24時間以上経過していたらTRUEを設定
      alert_flag = (current_user.last_alerted.nil? || ((Time.now - current_user.last_alerted).to_i)/(60*60*24) >= 1)
      if alert_flag
        books.each do |book|
          max_status = book.get_max_status
          # アラート：読了は除く
          if max_status != 9 && current_user.send("alert_days_status_" + max_status.to_s).present? &&
            (current_user.send("alert_days_status_" + max_status.to_s) < book.get_lapsed_days(max_status))
            flash_message = add_message( \
                              flash_message, book.title \
                            + "は「" + t("label.status.s#{max_status}") \
                            + "」登録から" + book.get_lapsed_days(max_status).to_s \
                            + "日経過しています！")
          end
        end
      end
      logger.debug("flashメッセージ：" + flash_message)
      if flash_message != ""
        flash[:warning] = flash_message
        current_user.update(last_alerted: Time.now)
      end
    end

    def add_message(flash_message, message)
      if flash_message != ""
        flash_message << "<br>"
      end
      flash_message << message
      flash_message
    end
end
