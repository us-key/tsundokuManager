class UsersController < ApplicationController

  def display_setting
    @user = current_user
  end

  def update_setting
    user = current_user
    if user.update(setting_params)
      # 登録成功
    else
      # 登録失敗
    end
    flash[:success] = "更新しました。"
    redirect_to books_path
  end

  private

    def setting_params
      params.require(:user).permit(:alert_days_status_0, :alert_days_status_3, :alert_days_status_7)
    end

end
