# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, optional: true
  belongs_to :updater, class_name: "User", foreign_key: :updated_by_id, optional: true

  attr_accessor :password

  validates :login_id, presence: true, length: { maximum: 15 }
  validates :password, presence: true, on: :create

  scope :active_status, -> { where(delete_flg: false) }
  scope :authenticatable, -> { active_status }

  before_validation :apply_password, if: :password_present?

  def self.authenticate(login_id, raw_password)
    user = authenticatable.find_by(login_id: login_id)
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
end
