# frozen_string_literal: true

class JournalEntryPatternsController < ApplicationController
  before_action :require_login!

  def index
    @patterns = JournalEntryPattern.order(:journal_entry_pattern_no)
  end
end
