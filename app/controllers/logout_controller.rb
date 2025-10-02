# frozen_string_literal: true

class LogoutController < ApplicationController
  def destroy
    reset_session
    redirect_to login_path, success: "ログアウトしました。"
  end
end
