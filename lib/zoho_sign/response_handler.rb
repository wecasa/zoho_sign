# frozen_string_literal: true

module ZohoSign
  class ResponseHandler
    def initialize(params)
      @params = params || {}
    end

    def body
      @params
    end

    def data(key)
      @params[key]
    end

    def success?
      @params[:status] == "success"
    end

    def error?
      @params[:status] == "error" || @params[:status] == "failure"
    end

    def message
      [
        @params[:message],
        ("error_param: #{@params[:error_param]}" if @params.key?(:error_param))
      ].join(" ")
    end

    def detailed_message
      @params.to_s
    end

    def has_more_rows?
      !!@params.dig(:page_context, :has_more_rows)
    end

    # @params = { code: 9004, status: "failure", message: "No match found" }
    def not_found_error?
      code?(9004)
    end

    # @params = { code: 9008, status: "failure", message: "templates occurs less than minimum occurance of 1", error_param: "templates" }
    def missing_param_error?
      code?(9008)
    end

    # @params = { code: 9015, status: "failure", message: "Extra key found", status: "failure", error_param: "data[page_context][row_count]" }
    def extra_key_found_error?
      code?(9015)
    end

    # @params = { code: 9031, status: "failure", message: "Ticket invalid" }
    def ticket_invalid_error?
      code?(9031)
    end

    # @params = { code: 9039, status: "failure", message: "Unable to process your request" }
    def extra_key_found_error?
      code?(9039)
    end

    # @params = { code: 9041, status: "failure", message: "Invalid Oauth token" }
    def invalid_token_error?
      code?(9041)
    end

    # @params = { code: 12001, status: "failure", message: "Upgrade API credits to access resources using API" }
    def no_more_credits_error?
      code?(12001)
    end

    private

    def code?(code)
      @params.key?(:code) && @params[:code] == code
    end
  end
end
