# frozen_string_literal: true

class RenameDepartmentsToBsDepartments < ActiveRecord::Migration[8.0]
  def change
    rename_table :departments, :bs_departments
  end
end
