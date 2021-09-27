# frozen_string_literal: true

require "pry"
require "webmock/rspec"
require "faker"

require "zoho_sign"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    ENV["ZOHO_SIGN_CLIENT_ID"] = "0000.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    ENV["ZOHO_SIGN_CLIENT_SECRET"] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ENV["ZOHO_SIGN_ACCESS_TOKEN"] = "0000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ENV["ZOHO_SIGN_REFRESH_TOKEN"] = "0000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  end
end
