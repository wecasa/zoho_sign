# frozen_string_literal: true

require "json"
require "faraday"
require "faraday_middleware"
require "addressable"

module ZohoSign
  # Class that takes care of authentication using Oauth2 workflow as described here:
  # https://www.zoho.com/crm/help/api/v2/#oauth-request.
  class Auth
    extend Forwardable

    AUTH_DOMAIN_PATH = "https://accounts.zoho.com"

    TOKEN_PATH = "/oauth/v2/token"

    DEFAULT_SCOPES = %w[
      ZohoSign.account.all
      ZohoSign.documents.all
      ZohoSign.templates.all
    ].freeze

    DEFAULT_ACCESS_TYPE = "offline"

    def initialize(access_type: DEFAULT_ACCESS_TYPE, scopes: DEFAULT_SCOPES)
      @configuration = ZohoSign.config
      @access_type = access_type
      @scopes = scopes
    end

    def self.refresh_token(refresh_token)
      new.refresh_token(refresh_token)
    end

    def refresh_token(refresh_token)
      uri = refresh_url(refresh_token)

      log "POST #{uri}"

      result = Faraday.post(uri)
      json = JSON.parse(result.body, symbolize_names: true)
      json.merge(refresh_token: refresh_token)
    end

    def refresh_url(refresh_token)
      uri = token_full_uri

      uri.query_values = {
        client_id: @configuration.oauth.client_id,
        client_secret: @configuration.oauth.client_secret,
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }

      Addressable::URI.unencode(uri.to_s)
    end

    def token_full_uri
      Addressable::URI.join(AUTH_DOMAIN_PATH, TOKEN_PATH)
    end

    private

    def log(text)
      return unless ZohoSign.config.debug

      puts Rainbow("[ZohoSign] #{text}").blue.bright
    end
  end
end
