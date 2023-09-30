# frozen_string_literal: true

require "dry-configurable"

require_relative "zoho_sign/version"
require_relative "zoho_sign/auth"
require_relative "zoho_sign/connection"

# Record classes
require_relative "zoho_sign/template"
require_relative "zoho_sign/document"

# Namespace ZohoSign
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
    setting :redirect_uri, default: "https://example.com"
  end

  setting :api do
    setting :auth_domain, default: "https://accounts.zoho.com"
    setting :domain, default: "https://sign.zoho.com"
    setting :base_path, default: "/api/v1"
  end

  setting :connection, reader: true, constructor: lambda { |params|
    return unless params
    raise Error, "ERROR: #{params[:error]}" if params && params[:error]

    connection_params = params.dup.slice(:access_token, :expires_in, :refresh_token)
    Connection.new(**connection_params)
  }

  class Error < StandardError; end

  class RecordNotFoundError < Error; end
end
