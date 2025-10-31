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

hidden_dept_codes = ["223-h1", "273-h1", "403-h1", "519-h1", "525-h1", "561-h2", "567-h1", "568-h1", "781-h1", "786-h1", "787-h1", "836-h1", "1100-h1", "1160-h1", "12-h1", "15-h1", "65-h1", "69-h1", "256-h1", "258-h1", "259-h1", "260-h1", "271-h1", "278-h1", "287-h1", "296-h1", "300-h1", "314-h1", "343-h1", "348-h1", "350-h1", "420-h1", "440-h1", "460-h1", "505-h1", "518-h1", "531-h1", "533-h1", "551-h1", "578-h1", "606-h1", "612-h1", "656-h1", "657-h1", "658-h1", "680-h1", "710-h1", "713-h1", "722-h1", "726-h1", "727-h1", "764-h1", "765-h1", "766-h1", "767-h1", "792-h1", "806-h1", "1001-h1", "1002-h1", "1050-h1", "1067-h1", "1236-h1", "223-h1", "273-h1", "403-h1", "519-h1", "525-h1", "561-h2", "567-h1", "568-h1", "781-h1", "786-h1", "787-h1", "836-h1", "1100-h1", "1160-h1"]

update_hidden_dept_codes(hidden_dept_codes)
