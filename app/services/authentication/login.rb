# frozen_string_literal: true

module Authentication
  class Login
    def self.call(login_id, raw_password)
      new(login_id, raw_password).call
    end

    def initialize(login_id, raw_password)
      @login_id = login_id
      @raw_password = raw_password
    end

    def call
      User.authenticate(login_id, raw_password)
    end

    private

    attr_reader :login_id, :raw_password
  end
end
