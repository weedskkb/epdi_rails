require 'nkf'

# UPDATE companies AS c JOIN bs_companies AS b ON c.code = CAST(b.id AS CHAR) SET c.name = b.name, c.business_connection_code = b.business_connection_code;


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

BsCompany.all.each do |bs_company|
  company = Company.find_by_code(bs_company.id)
  if company.nil?
    puts "not found company code=#{bs_company.id}"
  else
    s = str_similarity(bs_company.name, company.name, {hiragana_to_katakana: true, convert_half_to_full: true, upcase: true})
    if s < 0.2
      puts "#{format('%.2f', s)}, #{bs_company.id}, #{bs_company.name}, #{company.name}"
    end
  end
end
