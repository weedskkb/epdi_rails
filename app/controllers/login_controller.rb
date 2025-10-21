# frozen_string_literal: true

class LoginController < ApplicationController
  skip_before_action :enforce_session_timeout, only: %i[index create]
  before_action :redirect_if_signed_in, only: :index

  def index
    @form = LoginForm.new
  end

  def create
    @form = LoginForm.new(login_params)
    if @form.valid?
      user = Authentication::Login.call(@form.login_id, @form.password)
      if user
        reset_session
        session[:user_id] = user.id
        session[:last_seen_at] = Time.current
        redirect_to capture_payment_data_path, success: "ログインしました。"
      else
        flash.now[:alert] = "正しいログインID又はパスワードを入力してください"
        render :index, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "入力内容を確認してください"
      render :index, status: :unprocessable_entity
    end
  end

  private

  def login_params
    params.require(:login_form).permit(:login_id, :password)
  end

  def redirect_if_signed_in
    redirect_to capture_payment_data_path if signed_in?
  end
end
