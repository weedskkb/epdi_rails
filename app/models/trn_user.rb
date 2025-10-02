# frozen_string_literal: true

class TrnUser < ApplicationRecord
  self.table_name = "TRN_USER"
  self.primary_key = "USER_ID"

  alias_attribute :user_id, "USER_ID"
  alias_attribute :user_name, "USER_NAME"
  alias_attribute :login_id, "LOGIN_ID"
  alias_attribute :password_digest, "PASS_WORD"
  alias_attribute :salt, "SALT"
  alias_attribute :autholity_no, "AUTHOLITY_NO"
  alias_attribute :status_no, "STATUS_NO"
  alias_attribute :create_user_id, "CREATE_USER_ID"
  alias_attribute :create_date, "CREATE_DATE"
  alias_attribute :update_user_id, "UPDATE_USER_ID"
  alias_attribute :update_date, "UPDATE_DATE"
  alias_attribute :delete_flg, "DELETE_FLG"

  belongs_to :authority, class_name: "Authority", foreign_key: "AUTHOLITY_NO"
  belongs_to :status, class_name: "UserStatus", foreign_key: "STATUS_NO"
  belongs_to :creator, class_name: "TrnUser", foreign_key: "CREATE_USER_ID", optional: true
  belongs_to :updater, class_name: "TrnUser", foreign_key: "UPDATE_USER_ID", optional: true

  attr_accessor :password

  validates :login_id, presence: true, length: { maximum: 15 }
  validates :password, presence: true, on: :create

  scope :active_status, -> { where(STATUS_NO: 1, DELETE_FLG: false) }
  scope :authenticatable, -> { active_status }

  before_validation :apply_password, if: :password_present?
  before_create :stamp_creation_metadata
  before_save :touch_update_metadata

  def self.authenticate(login_id, raw_password)
    user = authenticatable.find_by(LOGIN_ID: login_id)
    return unless user&.salt && user.password_digest.present?

    PasswordService.verify?(user.password_digest, raw_password, user.salt) ? user : nil
  end

  private

  def apply_password
    salt_bytes = salt.presence || PasswordService.generate_salt
    hashed_password, generated_salt = PasswordService.hash_password(password, salt: salt_bytes)
    self.password_digest = hashed_password
    self.salt = generated_salt
  end

  def password_present?
    password.present?
  end

  def stamp_creation_metadata
    current_time = Time.current
    self.create_date ||= current_time
    self.update_date = current_time
  end

  def touch_update_metadata
    self.update_date = Time.current
  end
end
