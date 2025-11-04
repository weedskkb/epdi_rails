require 'nkf'

# INSERT departments (code, name, store_code, store_name, hidden) (select code, name, store_code, store_name, hidden from kkb_rails.departments);
## INSERT departments (code, name, store_code, store_name, company_id, hidden) (select id, name, id, name, company_id, delete_flg from bs_departments);
# UPDATE departments AS d JOIN bs_departments AS b ON CAST(d.code AS UNSIGNED) = b.id SET d.company_id = b.company_id;


def str_similarity(str1, str2, options = {})
  # ---- 前処理オプション ----
  normalize = lambda do |s|
    s = s.dup

    # ① 互換分解して等価化（㈱→(株)、半角→全角 など広く吸収）
    s = s.unicode_normalize(:nfkc)

    # 半角カタカナを全角に変換
    s = NKF.nkf('-w -X -Z1', s) if options[:convert_half_to_full]

    # ひらがなをカタカナに変換
    if options[:hiragana_to_katakana]
      s = s.tr('ぁ-ん', 'ァ-ン')
    end

    # 大文字⇔小文字変換
    s = s.upcase if options[:upcase]
    s = s.downcase if options[:downcase]

    s
  end

  s1 = normalize.call(str1)
  s2 = normalize.call(str2)

  # ---- 一致率計算 ----
  # Damerau–Levenshtein距離または単純なレーベンシュタイン距離で類似度を測定
  dist = levenshtein_distance(s1, s2)
  max_len = [s1.length, s2.length].max
  similarity = 1.0 - dist.to_f / max_len
  similarity
end

# ---- 補助: レーベンシュタイン距離 ----
def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  d = Array.new(m + 1) { Array.new(n + 1) }

  (0..m).each { |i| d[i][0] = i }
  (0..n).each { |j| d[0][j] = j }

  (1..m).each do |i|
    (1..n).each do |j|
      cost = s[i - 1] == t[j - 1] ? 0 : 1
      d[i][j] = [
        d[i - 1][j] + 1,    # 削除
        d[i][j - 1] + 1,    # 挿入
        d[i - 1][j - 1] + cost # 置換
      ].min
    end
  end

  d[m][n]
end

def update_hidden_dept_codes(codes)
  codes.each do |code|
    update_hidden_dept_code(code)
  end
end

def update_hidden_dept_code(code)
  base = code.sub(/-h\d+$/, "")
  dept1 = Department.find_by_code(code)
  dept2 = Department.find_by_code(code)
  if dept1 || dept2
    if dept1&.id == dept2&.id
      dept1.update(code: base, store_code: base)
      puts "#{code} -> #{base}"
    else
      puts "skip #{code} #{dept1&.id} #{dept2&.id}"
    end
  end
end

def check_hidden_depts(base_code, hidden_dept_codes)
  depts = Department.where("code REGEXP ?", "^#{base_code.to_s}-h[0-9]+$")
  if depts.size == 1
    dept = depts.first
    # puts "only one hidden dept: #{dept.name} #{dept.code} #{dept.store_code}"
    hidden_dept_codes << dept.code
    update_hidden_dept_code(dept.code)
  else depts.size > 1
    depts.each do |dept|
      puts "multiple hidden depts: #{dept.name} #{dept.code} #{dept.store_code}"
    end
  end
end

hidden_dept_codes = []

n_count = 0
s_count = 0
BsDepartment.all.each do |bs_department|
  department = Department.find_by_code(bs_department.id)
  if department.nil?
    # puts "not found department #{bs_department.id} #{bs_department.name}"
    puts "['#{bs_department.id}','#{bs_department.id}','#{bs_department.name}'],"
    check_hidden_depts(bs_department.id, hidden_dept_codes)
    n_count += 1
  else
    s = str_similarity(bs_department.name, department.name, {hiragana_to_katakana: true, convert_half_to_full: true, upcase: true})
    if s < 0.2
      # puts "#{format('%.2f', s)}, #{bs_department.id}, #{bs_department.name}, #{department.name}"
      s_count += 1
    end
  end
end

puts hidden_dept_codes.to_s
puts n_count, s_count
