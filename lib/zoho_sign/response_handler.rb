# frozen_string_literal: true

module ZohoSign
  # Internal class to centralize the code related to the response of the Zoho Sign API
  class ResponseHandler
    def initialize(response, http_response = nil)
      @response = response || {}
      @http_response = http_response
    end

    def body
      @response
    end

    def data(key)
      return unless @response.is_a?(Hash)

      @response[key]
    end

    def success?
      return false unless @response.is_a?(Hash)

      @response[:status] == "success"
    end

    def error?
      return false if @http_response == 200

      (!@http_response.nil? && @http_response != 200) ||
        @response[:status] == "error" ||
        @response[:status] == "failure"
    end

    def message
      [
        @response[:message],
        ("error_param: #{@response[:error_param]}" if @response.key?(:error_param))
      ].join(" ")
    end

    def detailed_message
      @response.to_s
    end

    def more_rows?
      !!@response.dig(:page_context, :has_more_rows)
    end

    # @response = { code: 9004, status: "failure", message: "No match found" }
    def not_found_error?
      code?(9004)
    end

    # @response = {
    #   code: 9008,
    #   status: "failure",
    #   message: "templates occurs less than minimum occurance of 1",
    #   error_param: "templates"
    # }
    def missing_param_error?
      code?(9008)
    end

    # @response = {
    #   code: 9015,
    #   status: "failure",
    #   message: "Extra key found",
    #   status: "failure",
    #   error_param: "data[page_context][row_count]"
    # }
    def extra_key_found_error?
      code?(9015)
    end

    # @response = { code: 9031, status: "failure", message: "Ticket invalid" }
    def ticket_invalid_error?
      code?(9031)
    end

    # @response = { code: 9039, status: "failure", message: "Unable to process your request" }
    def unable_to_process_request_error?
      code?(9039)
    end

    # @response = { code: 9041, status: "failure", message: "Invalid Oauth token" }
    def invalid_token_error?
      if @response.is_a?(Hash)
        code?(9041)
      else
        @http_response == 401 && @response.include?("Invalid Oauth token")
      end
    end

    # @response = { code: 12001, status: "failure", message: "Upgrade API credits to access resources using API" }
    def no_more_credits_error?
      code?(12_001)
    end

    private

    def code?(code)
      return unless @response.is_a?(Hash)

      @response.key?(:code) && @response[:code] == code
    end
  end
end
