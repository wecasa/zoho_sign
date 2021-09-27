# frozen_string_literal: true

require_relative "base_record"

module ZohoSign
  # Record class to interact with Zoho Sign Documents API
  class Document < ZohoSign::BaseRecord
    class << self
      private

      def request_path
        "requests"
      end

      def data_key
        :requests
      end
    end
  end
end
