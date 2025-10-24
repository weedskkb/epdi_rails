# frozen_string_literal: true

class SubAccount < ApplicationRecord
  scope :active, -> { where(delete_flg: false) }

  belongs_to :account, class_name: "Account", foreign_key: :code, primary_key: :code
end
