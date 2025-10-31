# frozen_string_literal: true

class UpdateTrnCaptureRecordsDepartmentFk < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :trn_capture_records, column: :department_id
  end
end
