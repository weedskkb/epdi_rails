# frozen_string_literal: true

module ApplicationHelper
  def main_menu_links
    [
      menu_item("支払データ取込", :capture_payment_data),
      menu_item("支払データ一覧", :payment_data),
      menu_item("仕訳データ作成", :journal_entry_data, divider_after: true),
      menu_item("会社マスタ", :companies),
      menu_item("部門マスタ", :departments),
      menu_item("取引先一覧", :business_connections),
      menu_item("勘定科目一覧", :accounting_items),
      menu_item("取込区分マスタ", :capture_categories),
      menu_item("仕訳パターン", :journal_entry_patterns, divider_after: true),
      menu_item("BS会社マスタ", :bs_companies),
      menu_item("BS部門マスタ", :bs_departments),
      menu_item("BS取引先マスタ", :suppliers),
      menu_item("BS勘定科目マスタ", :accounts),
      menu_item("BS補助科目マスタ", :sub_accounts),
      menu_item("BS勘定・補助一覧", :account_structures),
      menu_item("ユーザー管理", :users)
    ]
  end

  def list_count(collection)
    size = collection.respond_to?(:size) ? collection.size : Array(collection).size
    content_tag(:p, "全#{size}件", class: "table-meta")
  end

  private

  def menu_item(label, controller_name, divider_after: false)
    {
      label: label,
      path: menu_path_for(controller_name),
      divider_after: divider_after
    }
  end

  def menu_path_for(controller_name)
    url_for(controller: controller_name, action: :index, only_path: true)
  end

  def display_reference(identifier, name)
    return "" if identifier.nil? && name.blank?
    return name.to_s if identifier.nil?
    return identifier.to_s if name.blank?

    "#{name} (#{identifier})"
  end

  def display_timestamp(value)
    return "" if value.nil?

    value.strftime("%Y-%m-%d %H:%M")
  end
end
