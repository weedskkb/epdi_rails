# frozen_string_literal: true

require "openssl"
require "securerandom"
require "base64"

module PasswordService
  module_function

  ITERATIONS = 10_000
  KEY_LENGTH = 32
  DIGEST = "sha1"

  def generate_salt
    SecureRandom.random_bytes(16)
  end

  def hash_password(raw_password, salt: generate_salt)
    digest = OpenSSL::PKCS5.pbkdf2_hmac(raw_password, salt, ITERATIONS, KEY_LENGTH, DIGEST)
    [Base64.strict_encode64(digest), salt]
  end

  def verify?(hashed_password, raw_password, salt)
    candidate_hash, = hash_password(raw_password, salt: salt)

    ActiveSupport::SecurityUtils.secure_compare(candidate_hash, hashed_password)
  end
end
