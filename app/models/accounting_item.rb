require 'json'
require 'open-uri'

class AccountingItem < ApplicationRecord
  belongs_to :company, optional: true
  has_many :expense_items
  
  enum :disp_level, {disabled: 0, show_all: 1, show_keiri: 2}
  enum :debit_tax_type, {excluded: 0, tax_purchase: 1, tax_free_purchase: 2, common_purchase: 3, sale: 7, sale_returns: 8,
                        tax_free_sale: 16, transfer_securities: 17, tax_exempt_purchase: 101,
                        taxable_purchase_returns: 104, taxable_purchases_exempt_suppliers: 310,
                        common_tax_invoice_purchase: 312}, prefix: true
  enum :credit_tax_type, {excluded: 0, tax_purchase: 1, tax_free_purchase: 2, common_purchase: 3, sale: 7, sale_returns: 8,
                        tax_free_sale: 16, transfer_securities: 17, tax_exempt_purchase: 101,
                        taxable_purchase_returns: 104, taxable_purchases_exempt_suppliers: 310,
                        common_tax_invoice_purchase: 312}, prefix: true
  enum :tax_autocalc, {disabled_tax_autocalc: 0, tax_excluded_calc: 1, tax_included_calc: 2}
  enum :tax_rate, {normal_tax_rate: 0, reduced_tax_rate: 1}

  validates :code, presence: true

  def debit_tax_type_value
    AccountingItem.debit_tax_types[debit_tax_type]
  end

  def credit_tax_type_value
    AccountingItem.credit_tax_types[credit_tax_type]
  end

  def tax_autocalc_value
    AccountingItem.tax_autocalcs[tax_autocalc]
  end

  def tax_rate_value
    AccountingItem.tax_rates[tax_rate]
  end

  def self.common_or_weeds(hidden=nil)
    weeds_code = '1'
    items = self.left_outer_joins(:company).where(companies: {code: [weeds_code, nil]})
    items = items.where(hidden: hidden) unless hidden.nil?
    items
  end

  def self.transport?(code, sub_code)
    (code == '866' && sub_code != '2') || code == '859'
  end

  def transport?
    AccountingItem.transport?(self.code, self.sub_code)
  end

  def self.pull_bugyo
    create_items1, update_items1, hidden_items1 = self.pull_bugyo1
    create_items2, update_items2, hidden_items2 = self.pull_bugyo2
    [create_items1+create_items2, update_items1+update_items2, hidden_items1+hidden_items2]
  end

  def self.pull_bugyo1
    bugyo_basic_auth_user = GlobalValue.find_by(code: :bugyo_basic_auth_user)
    bugyo_basic_auth_pass = GlobalValue.find_by(code: :bugyo_basic_auth_pass)
    basic_auth = [bugyo_basic_auth_user.try(:value), bugyo_basic_auth_pass.try(:value)]
    bugyo_server_ip = GlobalValue.find_by(code: :bugyo_server_ip)
    uri = 'http://' + bugyo_server_ip.try(:value) + '/KanjoBugyo/api/AccountInfos?CompanyCode=1'
    response = URI.open(uri, read_timeout: 600, http_basic_authentication: basic_auth)
    array = JSON.load(response)

    ids = []
    create_items = []
    update_items = []
    hidden_items = []
    array.each do |value|
      if value['KamokuCode'].present?
        company = Company.find_by(code: value['CompanyCode'])
        puts "not found company code: #{value['CompanyCode']}" if company.blank?
        accounting_item = AccountingItem.find_by(code: value['KamokuCode'], sub_code: nil, company_id: [company.try(:id), nil])
        if accounting_item.blank?
          accounting_item = AccountingItem.create(code: value['KamokuCode'], sub_code: nil, company_id: nil, name: value['KamokuName'], disp_level: :disabled)
          create_items << accounting_item
        else
          if accounting_item.name != value['KamokuName']
            accounting_item.update(name: value['KamokuName'], hidden: false)
            update_items << accounting_item
          end
        end
        ids << accounting_item.id
      end
    end
    AccountingItem.common_or_weeds(false).where(sub_code: nil).each do |accounting_item|
      if !accounting_item.hidden? && !ids.include?(accounting_item.id)
        accounting_item.update(hidden: true)
        hidden_items << accounting_item
      end
    end
    puts "created: #{create_items.length}"
    puts "updated: #{update_items.length}"
    puts "hidden: #{hidden_items.length}"
    [create_items, update_items, hidden_items]
  end

  def self.pull_bugyo2
    bugyo_basic_auth_user = GlobalValue.find_by(code: :bugyo_basic_auth_user)
    bugyo_basic_auth_pass = GlobalValue.find_by(code: :bugyo_basic_auth_pass)
    basic_auth = [bugyo_basic_auth_user.try(:value), bugyo_basic_auth_pass.try(:value)]
    bugyo_server_ip = GlobalValue.find_by(code: :bugyo_server_ip)
    uri = 'http://' + bugyo_server_ip.try(:value) + '/KanjoBugyo/api/SubAccountInfos?CompanyCode=1'
    response = URI.open(uri, read_timeout: 600, http_basic_authentication: basic_auth)
    array = JSON.load(response)

    ids = []
    create_items = []
    update_items = []
    hidden_items = []
    array.each do |value|
      if value['KamokuCode'].present? && value['HojoKamokuCode'].present?
        company = Company.find_by(code: value['CompanyCode'])
        puts "not found company code: #{value['CompanyCode']}" if company.blank?
        accounting_item   = AccountingItem.find_by(code: value['KamokuCode'], sub_code: value['HojoKamokuCode'], company_id: [company.try(:id), nil])
        accounting_item_0   = AccountingItem.find_by(code: value['KamokuCode'], sub_code: nil, company_id: [company.try(:id), nil])
        if accounting_item.blank?
          accounting_item = AccountingItem.create(code: value['KamokuCode'], sub_code: value['HojoKamokuCode'], company_id: nil,
                                                  name: accounting_item_0.try(:name), sub_name: value['HojoKamokuName'], disp_level: :show_all)
          create_items << accounting_item
        else
          if accounting_item.name != value['KamokuName'] || accounting_item.sub_name != value['HojoKamokuName']
            accounting_item.update(name: accounting_item_0.try(:name), sub_name: value['HojoKamokuName'], hidden: false)
            update_items << accounting_item
          end
        end
        ids << accounting_item.id
      end
    end
    AccountingItem.common_or_weeds(false).where.not(sub_code: nil).each do |accounting_item|
      if !accounting_item.hidden? && !ids.include?(accounting_item.id)
        accounting_item.update(hidden: true)
        hidden_items << accounting_item
      end
    end
    puts "created: #{create_items.length}"
    puts "updated: #{update_items.length}"
    puts "hidden: #{hidden_items.length}"
    [create_items, update_items, hidden_items]
  end

  def name_with_code
    label_name(true)
  end

  def label_name(disp_label=false, inc_zero=true)
    if disp_label
      if sub_code.present? && (inc_zero || sub_code != '0')
        "#{name}／#{sub_name}(#{code}-#{sub_code})"
      else
        "#{name}(#{code})"
      end
    else
      if sub_code.present? && (inc_zero || sub_code != '0')
        "#{name}／#{sub_name}"
      else
        "#{name}"
      end
    end
  end

  def label_code
    if sub_code.present? && sub_code != '0'
      "#{code}-#{sub_code}"
    else
      code
    end
  end


  def name_with_code_and_company
    company_part = company ? "[#{company.name}] " : ""
    "#{company_part}#{label_name(true)}"
  end


  def self.export_bucket(items, item_class)
    errors = []
    data = CSV.generate do |csv|
      header = []
      header << '部門コード'
      header << '部門名'
      accounting_codes = [[866,0], [866,2], [866,3], [854,4], [859,1], [850,1], [850,2], [850,3], [850,4], [854,5], [854,6], [855,0],
                          [857,0], [858,1], [858,2], [858,3], [858,0], [860,0], [860,0], [860,2], [861,1], [861,2], [871,1], [871,2]]
      accounting_ids = []
      accounting_codes.each do |code|
        accounting_item =  AccountingItem.find_by(code: code[0], sub_code: code[1])
        if accounting_item.present?
          accounting_ids << accounting_item.try(:id)
          header << accounting_item.code + '-' + accounting_item.sub_code + accounting_item.name + '/' + accounting_item.sub_name
        else
          errors << "勘定項目が存在しません。(科目コード:#{code[0]}-#{code[1]})"
        end
      end
      csv << header

      items_by_department ={}
      items.each do |item|
        items_by_department[item.department_id] ||= []
        items_by_department[item.department_id] << item
      end

      items_by_department.each do |department_id, department_items|
        department = Department.find_by(id: department_id)
        if department.present?
          sum = {}
          department_items.each do |item|
            if item_class == :kkb_misc_exp_item
              accounting_item = item.accounting_item
            elsif item_class == :kkb_commuting_exp_item
              expense_item = item.expense_item
              accounting_item = expense_item.try(:accounting_item)
            end
            if accounting_ids.include?(accounting_item.try(:id))
              sum[accounting_item.id] ||= 0
              sum[accounting_item.id] += item.amount
            else
              errors << "想定外の勘定科目が指定されています。(科目コード:#{accounting_item.try(:code)}-#{accounting_item.try(:sub_code)})"
            end
          end
          row = []
          row << department.code
          row << department.name
          accounting_ids.each do |accounting_id|
            row << (sum[accounting_id].present? ? sum[accounting_id] : 0)
          end
          csv << row
        else
          errors << '部門と関連づけされていないレコードが存在します。'
        end
      end
    end
    [data, errors]
  end

  def self.human_enum_name(enum_name, enum_value)
    return "" if enum_value.blank?

    normalized_value = enum_value.to_s

    I18n.t(
      normalized_value,
      scope: [:enum, model_name.i18n_key, enum_name],
      default: [
        I18n.t(
          normalized_value,
          scope: [
            :activerecord,
            :attributes,
            model_name.i18n_key,
            enum_name.to_s.pluralize
          ],
          default: nil
        ),
        normalized_value.humanize
      ].compact
    )
  end
end
