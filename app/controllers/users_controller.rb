# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_login!
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.order(:id)
  end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, success: "ユーザーを登録しました。"
    else
      flash.now[:alert] = "ユーザーの登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, success: "ユーザー情報を更新しました。"
    else
      flash.now[:alert] = "ユーザー情報の更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, success: "ユーザーを削除しました。"
    else
      redirect_to users_path, alert: "ユーザーの削除に失敗しました。"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:login_id, :password, :delete_flg)
  end
end
