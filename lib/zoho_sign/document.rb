# frozen_string_literal: true

require_relative "base_record"

module ZohoSign
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

    def initialize(**attributes)
      @attributes = attributes
    end
  end
end
