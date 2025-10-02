# frozen_string_literal: true

class JournalEntryDataController < ApplicationController
  before_action :require_login!

  def index
    @journal_entries = JournalEntryData::Finder.new(current_user: current_user, params: params).all
  end
end
