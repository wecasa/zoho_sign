# frozen_string_literal: true

require "dry-configurable"

require_relative "zoho_sign/version"

module ZohoSign
  extend Dry::Configurable

  setting :debug, default: false

  # Follow the instruction found here to generate your credentails:
  # https://www.zoho.com/sign/api/#getting-started
  setting :oauth do
    setting :client_id
    setting :client_secret
    setting :access_token
    setting :refresh_token
  end

  setting :api do
    setting :domain, default: "https://sign.zoho.com"
    setting :base_path, default: "/api/v1"
  end

  class Error < StandardError; end
end
