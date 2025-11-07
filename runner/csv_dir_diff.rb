#!/usr/bin/env ruby
# frozen_string_literal: true

# ruby runner/csv_dir_diff.rb ../../check/LEFT ../../check/RIGHT --headers --ignore-cols CSJS005,CSJS100,CAPTURE_HISTORY_NO,CREATE_USER_ID,CREATE_DATE,CAPTURE_DATA_NO,JOURNAL_ENTRY_DATA_NO,DATE

# mysql -u kkb_rails -ppassword -D epdi -B -e "SELECT id as CAPTURE_DATA_NO, capture_history_id as CAPTURE_HISTORY_NO, row_no as ROW_NO, CAST(company_code AS UNSIGNED) as COMPANY_NO, CAST(department_code AS UNSIGNED) as DEPARTMENT_NO, business_connection_code as SUPPLIER_NO, account_code as ACCOUNT_NO, account_sub_code as SUB_ACCOUNT_NO, amount as AMOUNT, second_amount as SECOND_AMOUNT, tax_class_code as TAX_CLASS_NO, tax_rate_code as TAX_RATE_NO, created_at as CREATE_USER_ID, created_by_id as CREATE_DATE, list_cd as LIST_CD FROM trn_capture_records ORDER BY ROW_NO, ACCOUNT_NO" | sed 's/\t/,/g' > trn_capture_mydata.csv

# mysql -u kkb_rails -ppassword -D epdi -B -e "SELECT id as JOURNAL_ENTRY_DATA_NO, journal_entry_history_id as JOURNAL_ENTRY_HISTORY_NO, excel_row_no as EXCEL_ROW_NO, row_no as ROW_NO, date as DATE, CAST(company_code AS UNSIGNED) as COMPANY_NO, CAST(department_code AS UNSIGNED) as DEPARTMENT_NO, CAST(debit_department_code AS UNSIGNED) as DEBIT_DEPARTMENT_NO, debit_account_code as DEBIT_ACCOUNT_NO, debit_account_sub_code as DEBIT_SUB_ACCOUNT_NO, debit_amount as DEBIT_AMOUNT, debit_tax_class_code as DEBIT_TAX_CLASS_NO, debit_tax_rate_code as DEBIT_TAX_RATE_NO, debit_business_connection_code as DEBIT_SUPPLIER_NO, CAST(credit_department_code AS UNSIGNED) as CREDIT_DEPARTMENT_NO, credit_account_code as CREDIT_ACCOUNT_NO, credit_account_sub_code as CREDIT_SUB_ACCOUNT_NO, credit_amount as CREDIT_AMOUNT, credit_tax_class_code as CREDIT_TAX_CLASS_NO, credit_tax_rate_code as CREDIT_TAX_RATE_NO, credit_business_connection_code as CREDIT_SUPPLIER_NO, abstract as ABSTRACT, created_by_id as CREATE_USER_ID, created_at as CREATE_DATE FROM trn_journal_entry_records ORDER BY EXCEL_ROW_NO, ROW_NO, DEBIT_DEPARTMENT_NO, DEBIT_ACCOUNT_NO, DEBIT_SUB_ACCOUNT_NO, CREDIT_DEPARTMENT_NO, CREDIT_ACCOUNT_NO, CREDIT_SUB_ACCOUNT_NO, ABSTRACT" | sed 's/\t/,/g' > trn_journal_entry_mydata.csv


require 'csv'
require 'optparse'
require 'set'
begin
  require 'unicode_normalize'
rescue LoadError
  # Ruby 2.4+ なら標準で入っていますが、無ければ no-op に
  module UnicodeNormalizeShim
    def unicode_normalize(*); self; end
  end
  class String; include UnicodeNormalizeShim; end
end

options = {
  ignore_cols: [],
  headers: false,
  encoding: 'UTF-8',
  col_sep: ',',
  row_order_sensitive: false
}

op = OptionParser.new
op.banner = "Usage: ruby csv_dir_diff.rb LEFT_DIR RIGHT_DIR [options]"

op.on("--ignore-cols x,y,z", "比較除外列（列名 or 1始まりの列番号、カンマ区切り）") do |v|
  options[:ignore_cols] = v.split(',').map(&:strip).reject(&:empty?)
end
op.on("--headers", "1行目をヘッダとして扱う（列名指定が有効に）") { options[:headers] = true }
op.on("--encoding ENC", "文字コード（既定: UTF-8）") { |v| options[:encoding] = v }
op.on("--col-sep SEP", "列区切り文字（既定: ,）") { |v| options[:col_sep] = v }
op.on("--row-order-insensitive", "行順を無視（※セル差分は位置合わせ）") { options[:row_order_sensitive] = false }
op.on("--row-order-sensitive", "行順も比較（セル差分は元の行番号で表示）") { options[:row_order_sensitive] = true }
op.on("-h", "--help", "Show help") { puts op; exit }

begin
  left_dir, right_dir, *rest = op.parse!(ARGV)
  raise ArgumentError, "LEFT_DIR and RIGHT_DIR are required" unless left_dir && right_dir
rescue => e
  warn e.message
  warn op
  exit 1
end

def list_csvs(dir)
  Dir.glob(File.join(dir, "**", "*.csv")).map { |p| File.expand_path(p) }
end

# 末尾の "_" 以降（"_" 含む）を除いた basename（拡張子除去）をキーにする
# 例: foo_bar_202410.csv => "foo_bar"
def basename_key(path)
  base = File.basename(path, ".*")
  idx = base.rindex('_')
  idx ? base[0...idx] : base
end

# ヘッダ名・指定名の正規化：NFKC + strip
def norm_name(s)
  s.to_s.unicode_normalize(:nfkc).strip
end

def parse_ignore_indices(ignore_cols, headers, header_to_index)
  indices = []
  ignore_cols.each do |c|
    if c =~ /\A\d+\z/ # 1-based index
      indices << (c.to_i - 1)
    else
      if headers
        idx = header_to_index[norm_name(c)]
        if idx.nil?
          warn "[WARN] ignore-cols '#{c}' not found in header; will ignore nothing for this name"
        else
          indices << idx
        end
      else
        warn "[WARN] ignore-cols '#{c}' given as name but --headers is not set; ignored"
      end
    end
  end
  indices.uniq.sort
end

def normalize_row(row, ignore_indices)
  row.each_with_index.reject { |_, i| ignore_indices.include?(i) }.map(&:first)
end

def read_csv(path, options)
  enc = options[:encoding]
  col_sep = options[:col_sep]
  headers = options[:headers]

  rows = []
  header = nil

  File.open(path, "rb") do |f|
    content = f.read
    # 読み込み時に invalid を置換して落ちにくく / BOM除去
    content = content&.force_encoding(enc)&.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    content.sub!(/\A\uFEFF/, '') # 先頭BOMがあれば除去

    CSV.new(content, col_sep: col_sep, headers: headers, return_headers: false).each do |row|
      if headers && header.nil?
        header = row.headers
      end
      rows << (headers ? row.fields : row)
    end
  end

  [header, rows]
rescue => e
  raise "Failed to read CSV: #{path} (#{e.class}: #{e.message})"
end

# セル単位の差分（l/r の行を位置で突き合わせ）
def diff_cells(norm_l, norm_r, col_labels)
  diffs = []
  max_len = [norm_l.length, norm_r.length].max
  max_len.times do |i|
    l = norm_l[i]
    r = norm_r[i]
    if l && r
      max_cols = [l.size, r.size].max
      max_cols.times do |j|
        lv = l[j]
        rv = r[j]
        next if lv == rv
        diffs << { row: i + 1, col: j + 1, col_name: (col_labels && col_labels[j]), left: lv, right: rv }
      end
    elsif l && !r
      diffs << { row: i + 1, col: nil, col_name: nil, left: l.join(','), right: nil, note: 'row-only-left' }
    elsif r && !l
      diffs << { row: i + 1, col: nil, col_name: nil, left: nil, right: r.join(','), note: 'row-only-right' }
    end
  end
  diffs
end

def build_key_map(paths)
  h = Hash.new { |hh, k| hh[k] = [] }
  paths.each { |p| h[basename_key(p)] << p }
  h
end

# 詳細は配列で返し、サマリー用に OK/NG も返す
# 戻り値: { key:, status: :ok/:ng, left:, right:, details: [String...] }
def compare_one_pair_collect(key, left_path, right_path, options)
  header_l, rows_l = read_csv(left_path, options)
  header_r, rows_r = read_csv(right_path, options)

  result = { key: key, left: left_path, right: right_path, status: :ng, details: [] }

  if options[:headers]
    # ヘッダ名を正規化
    norm_header_l = header_l.map { |h| norm_name(h) }
    norm_header_r = header_r.map { |h| norm_name(h) }

    # 共通列
    common_cols = norm_header_l & norm_header_r
    if common_cols.empty?
      result[:details] << "[DIFF] key='#{key}' NG"
      result[:details] << "  LEFT : #{left_path}"
      result[:details] << "  RIGHT: #{right_path}"
      result[:details] << "  (no common headers; skip)"
      return result
    end

    # 列名→index（正規化名で引く）
    h2i_l = norm_header_l.each_with_index.to_h
    h2i_r = norm_header_r.each_with_index.to_h

    # 除外列：名前も数値もサポート
    ignore_idx_l = parse_ignore_indices(options[:ignore_cols], true, h2i_l)
    ignore_idx_r = parse_ignore_indices(options[:ignore_cols], true, h2i_r)
    ignore_names_by_num_l = ignore_idx_l.map { |i| norm_header_l[i] }.compact
    ignore_names_by_num_r = ignore_idx_r.map { |i| norm_header_r[i] }.compact

    ignore_names_by_opt = options[:ignore_cols].reject { |x| x =~ /\A\d+\z/ }.map { |x| norm_name(x) }
    ignore_names_all = (ignore_names_by_opt + ignore_names_by_num_l + ignore_names_by_num_r).uniq

    # 比較に使う列 = 共通列 - 除外列名（正規化済）
    compare_names = common_cols - ignore_names_all
    if compare_names.empty?
      result[:status] = :ok
      result[:details] << "[DIFF] key='#{key}' OK"
      return result
    end

    idx_l = compare_names.map { |name| h2i_l[name] }.compact
    idx_r = compare_names.map { |name| h2i_r[name] }.compact

    norm_l = rows_l.map { |row| idx_l.map { |i| row[i] } }
    norm_r = rows_r.map { |row| idx_r.map { |i| row[i] } }

    col_labels = compare_names
    c_diffs = diff_cells(norm_l, norm_r, col_labels)

    if c_diffs.empty?
      result[:status] = :ok
      result[:details] << "[DIFF] key='#{key}' OK"
    else
      result[:status] = :ng
      result[:details] << "[DIFF] key='#{key}' NG"
      result[:details] << "  LEFT : #{left_path}"
      result[:details] << "  RIGHT: #{right_path}"
      c_diffs.each do |d|
        if d[:note] == 'row-only-left'
          result[:details] << "  - row #{d[:row]} (only in LEFT): #{d[:left]}"
        elsif d[:note] == 'row-only-right'
          result[:details] << "  + row #{d[:row]} (only in RIGHT): #{d[:right]}"
        else
          label = d[:col_name] ? "#{d[:col_name]}(#{d[:col]})" : "col #{d[:col]}"
          result[:details] << "  * row #{d[:row]},  #{label}: LEFT='#{d[:left]}' RIGHT='#{d[:right]}'"
        end
      end
    end

  else
    # ヘッダなし
    max_cols = [rows_l.map(&:size).max || 0, rows_r.map(&:size).max || 0].max
    dummy_header = (1..max_cols).map(&:to_s)
    h2i_dummy = dummy_header.each_with_index.to_h
    ignore_idx = parse_ignore_indices(options[:ignore_cols], false, h2i_dummy)

    norm_l = rows_l.map { |row| normalize_row(row + Array.new(max_cols - row.size), ignore_idx) }
    norm_r = rows_r.map { |row| normalize_row(row + Array.new(max_cols - row.size), ignore_idx) }

    c_diffs = diff_cells(norm_l, norm_r, nil)
    if c_diffs.empty?
      result[:status] = :ok
      result[:details] << "[DIFF] key='#{key}' OK"
    else
      result[:status] = :ng
      result[:details] << "[DIFF] key='#{key}' NG"
      result[:details] << "  LEFT : #{left_path}"
      result[:details] << "  RIGHT: #{right_path}"
      c_diffs.each do |d|
        if d[:note] == 'row-only-left'
          result[:details] << "  - row #{d[:row]} (only in LEFT): #{d[:left]}"
        elsif d[:note] == 'row-only-right'
          result[:details] << "  + row #{d[:row]} (only in RIGHT): #{d[:right]}"
        else
          label = "col #{d[:col]}"
          result[:details] << "  * row #{d[:row]},  #{label}: LEFT='#{d[:left]}' RIGHT='#{d[:right]}'"
        end
      end
    end
  end

  result
end

# ===== メイン処理 =====
left_paths  = list_csvs(left_dir)
right_paths = list_csvs(right_dir)

left_map  = build_key_map(left_paths)
right_map = build_key_map(right_paths)

all_keys = (left_map.keys | right_map.keys).sort

ok_items = []      # ["key", ...]
ng_items = []      # ["key", "key (ONLY LEFT)", ...]  ※ ONLY もここに入れる
detail_blocks = [] # [ ["line1", "line2", ...], ... ]
only_lines = []    # ONLY LEFT/RIGHT の詳細を最後に出す

all_keys.each do |key|
  ls = (left_map[key]  || []).sort_by { |p| File.basename(p) }
  rs = (right_map[key] || []).sort_by { |p| File.basename(p) }

  if ls.empty? && !rs.empty?
    rs.each do |p|
      only_lines << "[ONLY RIGHT] key='#{key}' -> #{p}"
      ng_items   << "#{key} (ONLY RIGHT)"
    end
    next
  elsif rs.empty? && !ls.empty?
    ls.each do |p|
      only_lines << "[ONLY LEFT]  key='#{key}' -> #{p}"
      ng_items   << "#{key} (ONLY LEFT)"
    end
    next
  end

  # 両側にある場合：basename昇順で一対一に対応付け、余りはONLY扱い
  pairs = ls.zip(rs).reject { |l, r| l.nil? || r.nil? }
  extras_left  = ls.drop(pairs.size)
  extras_right = rs.drop(pairs.size)

  pairs.each do |l, r|
    res = compare_one_pair_collect(key, l, r, options)
    (res[:status] == :ok ? ok_items : ng_items) << res[:key]
    detail_blocks << res[:details]
  end

  extras_left.each  do |p|
    only_lines << "[ONLY LEFT]  key='#{key}' (unpaired) -> #{p}"
    ng_items   << "#{key} (ONLY LEFT, unpaired)"
  end
  extras_right.each do |p|
    only_lines << "[ONLY RIGHT] key='#{key}' (unpaired) -> #{p}"
    ng_items   << "#{key} (ONLY RIGHT, unpaired)"
  end
end

# ===== ここから出力 =====

# 1) サマリー（OK / NG 一覧）※ ONLY も NG に集約
puts "===== SUMMARY ====="
puts "[OK] (#{ok_items.size})"
ok_items.each { |k| puts "  #{k}" }
puts "[NG] (#{ng_items.size})"
ng_items.each { |k| puts "  #{k}" }

# 2) 詳細（従来どおり）
puts "\n===== DETAILS ====="
detail_blocks.each do |block|
  block.each { |line| puts line }
end

# 3) 片側のみ（参考に最後で）
unless only_lines.empty?
  puts "\n===== ONLY SIDE ====="
  only_lines.each { |line| puts line }
end
