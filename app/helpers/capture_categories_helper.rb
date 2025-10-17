# frozen_string_literal: true

module CaptureCategoriesHelper
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
