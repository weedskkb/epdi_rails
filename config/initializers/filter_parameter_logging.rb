# frozen_string_literal: true

# Configure parameters to be filtered from the log files.
Rails.application.config.filter_parameters += %i[
  password
  password_confirmation
]
