# frozen_string_literal: true

module ApplicationHelper
  def main_menu_links
    [
      ["支払データ取込", menu_path_for(:capture_payment_data)],
      ["支払データ一覧", menu_path_for(:payment_data)],
      ["仕訳データ作成", menu_path_for(:journal_entry_data)],
      ["会社マスタ", menu_path_for(:companies)],
      ["部門マスタ", menu_path_for(:departments)],
      ["勘定科目一覧", menu_path_for(:accounting_items)],
      ["勘定科目マスタ(BS)", menu_path_for(:accounts)],
      ["補助科目マスタ(BS)", menu_path_for(:sub_accounts)],
      ["勘定・補助一覧(BS)", menu_path_for(:account_structures)],
      ["取込区分マスタ", menu_path_for(:capture_categories)],
      ["取引先マスタ", menu_path_for(:suppliers)],
      ["仕訳パターン", menu_path_for(:journal_entry_patterns)],
      ["ユーザー管理", menu_path_for(:users)]
    ]
  end

  private

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
