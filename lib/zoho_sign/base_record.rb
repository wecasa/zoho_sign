# frozen_string_literal: true

require "json"
require "active_support/core_ext/object/to_query"

module ZohoSign
  # The main class for record classes
  class BaseRecord
    # Default number of records when fetching all.
    DEFAULT_RECORDS_PER_REQUEST = 100

    # Default starting index point when fetching all.
    DEFAULT_START_INDEX = 1

    attr_accessor :attributes

    class << self
      # @param [Integer] :start_index (1) Start Index.
      # @param [Integer] :per_request (100) No of rows to be retrieved. Possible values: 10, 25, 50 or 100.
      # @param [String] :sort_column (nil)
      # @param [String] :sort_order (nil)
      #
      # @return [Array] Array of instances of current class
      def all(start_index: DEFAULT_START_INDEX, per_request: DEFAULT_RECORDS_PER_REQUEST, sort_column: nil, sort_order: nil)
        params = build_params_for_index_action(start_index, per_request, sort_column, sort_order)
        body = connection.get(request_path, params)
        response = build_response(body)
        data = response.data(data_key)

        loop do
          break unless response.more_rows?

          start_index += response.data(data_key).count
          params = build_params_for_index_action(start_index, per_request, sort_column, sort_order)
          body = connection.get(request_path, params)
          response = build_response(body)
          data += response.data(data_key)
        end

        data.map { |record_attributes| new(**record_attributes) }
      end

      # @param [String] zoho_id
      #
      # @return [Class] Instance of current class
      def find(zoho_id)
        body = connection.get("#{request_path}/#{zoho_id}")
        response = build_response(body)
        record_attributes = response.data(data_key)
        new(**record_attributes)
      end

      private

      def connection
        ZohoSign.connection
      end

      def request_path
        raise ZohoSign::Error, "this method should be overwrite in the child class. Please open an issue at https://github.com/wecasa/zoho_sign"
      end

      def data_key
        raise ZohoSign::Error, "this method should be overwrite in the child class. Please open an issue at https://github.com/wecasa/zoho_sign"
      end

      def build_response(body)
        response = ZohoSign::ResponseHandler.new(body)
        return response if response.success?

        raise RecordNotFoundError, response.message if response.not_found_error?

        # This is a fallback because ZohoSign API could evolve by adding new error messages.
        raise Error, response.detailed_message
      end

      def build_params_for_index_action(start_index, row_count, sort_column, sort_order)
        {
          data: {
            page_context: {
              start_index: start_index,
              row_count: row_count,
              sort_column: sort_column,
              sort_order: sort_order
            }.compact
          }.compact.to_json
        }.compact
      end
    end

    def initialize(**attributes)
      @attributes = attributes
    end
  end
end
