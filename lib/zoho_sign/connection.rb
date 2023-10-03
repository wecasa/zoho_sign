# frozen_string_literal: true

require "rainbow"
require "faraday"
require "faraday/retry"

require_relative "response_handler"

module ZohoSign
  # Internal class that has all the logic to stablish a connection with Zoho API
  class Connection
    attr_accessor :access_token, :refresh_token, :api_domain, :api_base_path, :expires_ins

    def initialize(access_token:, refresh_token: nil, api_domain: nil, api_base_path: nil, expires_in: 3600)
      @access_token = access_token
      @refresh_token ||= refresh_token # Do not overwrite if it's already set
      @api_domain = api_domain || ZohoSign.config.api.domain
      @api_base_path = api_base_path || ZohoSign.config.api.base_path
      @expires_in = expires_in
    end

    def get(path, params = {})
      log "GET #{path} with #{params}"

      response = with_refresh { adapter.get(path, params) }
      response.body
    end

    def post(path, params = {}.to_query)
      log "POST #{path} with #{params}"

      response = with_refresh { adapter.post(path, params) }
      response.body
    end

    def upload(path, params = {})
      log "Uploading to #{path} with #{params}"

      response = with_refresh { file_upload_adapter.post(path, params) }
      response.body
    end

    def put(path, params = {})
      log "PUT #{path} with #{params}"

      response = with_refresh { adapter.put(path, params) }
      response.body
    end

    def delete(path, params = {})
      log "DELETE #{path} with #{params}"

      response = with_refresh { adapter.delete(path, params) }
      response.body
    end

    def download(path, params = {})
      log "GET #{path} with #{params}"

      response = with_refresh { download_adapter.get(path, params) }
      response.body
    end

    private

    def log(text)
      return unless ZohoSign.config.debug

      puts Rainbow("[ZohoSign] #{text}").blue.bright
    end

    def with_refresh
      http_response = yield
      response = ZohoSign::ResponseHandler.new(http_response.body, http_response.status)
      # Try to refresh the token and try again
      if response.invalid_token_error? && refresh_token?
        log "Refreshing outdated token... #{@access_token}"
        params = ZohoSign::Auth.refresh_token(@refresh_token)
        @access_token = params[:access_token]
        http_response = yield
        response = ZohoSign::ResponseHandler.new(http_response.body, http_response.status)
      end

      raise ZohoSign::Error, response.detailed_message if response.error?

      response
    end

    def base_url
      "#{@api_domain}#{@api_base_path}"
    end

    def authorization_token
      "Zoho-oauthtoken #{@access_token}"
    end

    def access_token?
      !@access_token.empty?
    end

    def refresh_token?
      !@refresh_token.empty?
    end

    def adapter
      Faraday.new(url: base_url) do |conn|
        conn.headers["Authorization"] = authorization_token if access_token?
        conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        conn.request :json
        conn.request :retry
        conn.response :json, parser_options: {symbolize_names: true}, content_type: /\bjson$/
        conn.response :logger if ZohoSign.config.debug
        conn.adapter Faraday.default_adapter
      end
    end

    def file_upload_adapter
      Faraday.new(url: base_url) do |conn|
        conn.headers["Authorization"] = authorization_token if access_token?
        conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        conn.request :multipart
        conn.request :url_encoded
        conn.response :json, parser_options: {symbolize_names: true}, content_type: /\bjson$/
        conn.response :logger if ZohoSign.config.debug
        conn.adapter Faraday.default_adapter
      end
    end

    def download_adapter
      Faraday.new(url: base_url) do |conn|
        conn.headers["Authorization"] = authorization_token if access_token?
        conn.headers["Content-Type"] = "application/x-www-form-urlencoded"
        conn.request :retry
        conn.response :json, parser_options: {symbolize_names: true}, content_type: /\bjson$/
        conn.response :logger if ZohoSign.config.debug
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
