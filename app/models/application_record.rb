# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  private

  def read_migrated_attribute(primary_name, legacy_name)
    if attribute_available?(primary_name)
      self[primary_name]
    elsif attribute_available?(legacy_name)
      self[legacy_name]
    else
      nil
    end
  end

  def write_migrated_attribute(primary_name, legacy_name, value)
    if attribute_available?(primary_name)
      self[primary_name] = value
    elsif attribute_available?(legacy_name)
      self[legacy_name] = value
    else
      raise ActiveModel::MissingAttributeError, "Cannot write attribute #{primary_name || legacy_name}"
    end
  end

  def attribute_available?(name)
    return false if name.blank?

    attributes.key?(name.to_s)
  end
end
