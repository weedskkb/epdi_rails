# frozen_string_literal: true

class Account < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  has_many :sub_accounts, class_name: "SubAccount", foreign_key: :code, primary_key: :code
end
