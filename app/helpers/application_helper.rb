# frozen_string_literal: true

module ApplicationHelper
  def main_menu_links
    [
      ["支払データ取込", menu_path_for(:capture_payment_data)],
      ["支払データ一覧", menu_path_for(:payment_data)],
      ["仕訳データ作成", menu_path_for(:journal_entry_data)],
      ["会社マスタ", menu_path_for(:companies)],
      ["部門マスタ", menu_path_for(:departments)],
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
end
