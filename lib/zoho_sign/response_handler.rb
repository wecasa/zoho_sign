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

    # Body: { code: 9041, message: "Invalid Oauth token", status: "failure" }
    def invalid_token_error?
      code?(9041)
    end

    # Body: { code: 9004, message: "No match found", status: "failure" }
    def not_found_error?
      code?(9004)
    end

    # Body: { code: 9015, error_param: "data[page_context][row_count]", message: "Extra key found", status: "failure" }
    def extra_key_found_error?
      code?(9015)
    end

    private

    def code?(code)
      @params.key?(:code) && @params[:code] == code
    end
  end
end
