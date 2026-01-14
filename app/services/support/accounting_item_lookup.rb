# frozen_string_literal: true

module Support
  module AccountingItemLookup
    MissingItemError = Class.new(StandardError)

    private

    def accounting_item_for(account_code, account_sub_code)
      return nil if account_code.blank?

      normalized_code = account_code.to_s
      normalized_sub_code = normalize_sub_code(account_sub_code)
      cache_key = "#{normalized_code}:#{normalized_sub_code || '-'}"

      accounting_item_cache[cache_key] ||= AccountingItem.find_by(
        company_id: nil,
        code: normalized_code,
        sub_code: normalized_sub_code
      ) # TODO: 後で確認
    end

    def normalize_sub_code(value)
      return nil if value.blank?

      string = value.to_s.strip
      string.empty? ? nil : string
    end

    def accounting_item_cache
      @accounting_item_lookup_cache ||= {}
    end
  end
end
