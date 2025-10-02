# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :success, :warning

  before_action :enforce_session_timeout

  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= TrnUser.authenticatable.find_by("USER_ID" => session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_login!
    return if signed_in?

    redirect_to login_path, alert: "ログインが必要です。"
  end

  def enforce_session_timeout
    return unless session[:user_id]

    if session[:last_seen_at].present? && session[:last_seen_at] < 2.hours.ago
      reset_session
      redirect_to login_path, alert: "セッションの有効期限が切れました。"
    else
      session[:last_seen_at] = Time.current
    end
  end
end
