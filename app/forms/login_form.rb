# frozen_string_literal: true

class LoginForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :login_id, :string
  attribute :password, :string

  validates :login_id, presence: true
  validates :password, presence: true
end
