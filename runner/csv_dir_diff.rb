#!/usr/bin/env ruby
# frozen_string_literal: true
# ruby runner/csv_dir_diff.rb ../../check/LEFT ../../check/RIGHT --headers --ignore-cols CSJS005,CSJS100

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
def diff_cells(norm_l, norm_r, col_labels, label_prefix: nil)
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
        diffs << { row: i + 1, col: j + 1, col_name: (col_labels && col_labels[j]),
                   left: lv, right: rv, tag: label_prefix }
      end
    elsif l && !r
      diffs << { row: i + 1, col: nil, col_name: nil, left: l.join(','), right: nil,
                 note: 'row-only-left', tag: label_prefix }
    elsif r && !l
      diffs << { row: i + 1, col: nil, col_name: nil, left: nil, right: r.join(','), 
                 note: 'row-only-right', tag: label_prefix }
    end
  end
  diffs
end

def build_key_map(paths)
  h = Hash.new { |hh, k| hh[k] = [] }
  paths.each { |p| h[basename_key(p)] << p }
  h
end

def compare_one_pair(key, left_path, right_path, options)
  header_l, rows_l = read_csv(left_path, options)
  header_r, rows_r = read_csv(right_path, options)

  puts "[DIFF] key='#{key}'"
  puts "  LEFT : #{left_path}"
  puts "  RIGHT: #{right_path}"

  if options[:headers]
    # ヘッダ名を正規化
    norm_header_l = header_l.map { |h| norm_name(h) }
    norm_header_r = header_r.map { |h| norm_name(h) }

    # 共通列
    common_cols = norm_header_l & norm_header_r
    if common_cols.empty?
      puts "  (no common headers; skip)"
      return
    end

    # 列名→index（正規化名で引く）
    h2i_l = norm_header_l.each_with_index.to_h
    h2i_r = norm_header_r.each_with_index.to_h

    # 除外列：名前も数値もサポート（数値で指定された場合は該当名を抽出）
    ignore_idx_l = parse_ignore_indices(options[:ignore_cols], true, h2i_l)
    ignore_idx_r = parse_ignore_indices(options[:ignore_cols], true, h2i_r)
    ignore_names_by_num_l = ignore_idx_l.map { |i| norm_header_l[i] }.compact
    ignore_names_by_num_r = ignore_idx_r.map { |i| norm_header_r[i] }.compact

    ignore_names_by_opt = options[:ignore_cols].reject { |x| x =~ /\A\d+\z/ }.map { |x| norm_name(x) }
    ignore_names_all = (ignore_names_by_opt + ignore_names_by_num_l + ignore_names_by_num_r).uniq

    # 比較に使う列 = 共通列 - 除外列名（正規化済）
    compare_names = common_cols - ignore_names_all
    if compare_names.empty?
      puts "  (no columns to compare after ignoring: #{options[:ignore_cols].join(', ')})"
      return
    end

    idx_l = compare_names.map { |name| h2i_l[name] }.compact
    idx_r = compare_names.map { |name| h2i_r[name] }.compact

    # 行を比較用に（共通列のみ）
    norm_l = rows_l.map { |row| idx_l.map { |i| row[i] } }
    norm_r = rows_r.map { |row| idx_r.map { |i| row[i] } }

    # --- 常にセル単位で差分出力 ---
    # 行順無視モードでも、ここでは“そのままの行順で”位置合わせしてセル差分を出す
    col_labels = compare_names
    c_diffs = diff_cells(norm_l, norm_r, col_labels)

    if c_diffs.empty?
      puts "  (no cell differences after ignoring cols: #{options[:ignore_cols].join(', ')})"
    else
      c_diffs.each do |d|
        if d[:note] == 'row-only-left'
          puts "  - row #{d[:row]+1} (only in LEFT): #{d[:left]}"
        elsif d[:note] == 'row-only-right'
          puts "  + row #{d[:row]+1} (only in RIGHT): #{d[:right]}"
        else
          label = d[:col_name] ? "#{d[:col_name]}(#{d[:col]})" : "col #{d[:col]}"
          puts "  * row #{d[:row]+1},  #{label}: LEFT='#{d[:left]}' RIGHT='#{d[:right]}'"
        end
      end
    end
  else
    # ヘッダなし：除外列はインデックスで処理
    max_cols = [rows_l.map(&:size).max || 0, rows_r.map(&:size).max || 0].max
    dummy_header = (1..max_cols).map(&:to_s)
    h2i_dummy = dummy_header.each_with_index.to_h
    ignore_idx = parse_ignore_indices(options[:ignore_cols], false, h2i_dummy)

    norm_l = rows_l.map { |row| normalize_row(row + Array.new(max_cols - row.size), ignore_idx) }
    norm_r = rows_r.map { |row| normalize_row(row + Array.new(max_cols - row.size), ignore_idx) }

    # --- 常にセル単位 ---
    col_labels = nil
    c_diffs = diff_cells(norm_l, norm_r, col_labels)
    if c_diffs.empty?
      puts "  (no cell differences after ignoring indices: #{options[:ignore_cols].join(', ')})"
    else
      c_diffs.each do |d|
        if d[:note] == 'row-only-left'
          puts "  - row #{d[:row]+1} (only in LEFT): #{d[:left]}"
        elsif d[:note] == 'row-only-right'
          puts "  + row #{d[:row]+1} (only in RIGHT): #{d[:right]}"
        else
          label = "col #{d[:col]}"
          puts "  * row #{d[:row]+1},  #{label}: LEFT='#{d[:left]}' RIGHT='#{d[:right]}'"
        end
      end
    end
  end
end

# ===== メイン処理 =====
left_paths  = list_csvs(left_dir)
right_paths = list_csvs(right_dir)

left_map  = build_key_map(left_paths)
right_map = build_key_map(right_paths)

all_keys = (left_map.keys | right_map.keys).sort

all_keys.each do |key|
  ls = (left_map[key]  || []).sort_by { |p| File.basename(p) }
  rs = (right_map[key] || []).sort_by { |p| File.basename(p) }

  if ls.empty? && !rs.empty?
    rs.each { |p| puts "[ONLY RIGHT] key='#{key}' -> #{p}" }
    next
  elsif rs.empty? && !ls.empty?
    ls.each { |p| puts "[ONLY LEFT]  key='#{key}' -> #{p}" }
    next
  end

  # 両側にある場合：basename昇順で一対一に対応付け、余りはONLY扱い
  pairs = ls.zip(rs).reject { |l, r| l.nil? || r.nil? }
  extras_left  = ls.drop(pairs.size)
  extras_right = rs.drop(pairs.size)

  pairs.each { |l, r| compare_one_pair(key, l, r, options) }
  extras_left.each  { |p| puts "[ONLY LEFT]  key='#{key}' (unpaired) -> #{p}" }
  extras_right.each { |p| puts "[ONLY RIGHT] key='#{key}' (unpaired) -> #{p}" }
end
