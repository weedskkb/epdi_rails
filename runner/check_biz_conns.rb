
codes = Company.all.pluck(:business_connection_code).compact.uniq  # 2110 not found 未定
# codes = CaptureCategory.all.pluck(:business_connection_code).compact.uniq
# codes = JournalEntryPattern.all.pluck(:debit_business_connection_code).compact.uniq  # 1,2 not found => OK
# codes = JournalEntryPattern.all.pluck(:credit_business_connection_code).compact.uniq  # 1,2 not found => OK
codes.each do |code|
  biz_conn = BusinessConnection.find_by_code(code)
  if biz_conn.nil?
    puts "#{code} Not Found"
  end
end
