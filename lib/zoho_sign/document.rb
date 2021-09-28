# frozen_string_literal: true

require_relative "base_record"

module ZohoSign
  # Record class to interact with Zoho Sign Documents API
  class Document < ZohoSign::BaseRecord
    class << self
      # @param [String] :document_id Zoho Sign Document ID
      #
      # @return [Class] Tempfile instance
      def download_pdf(document_id)
        body = connection.download("#{request_path}/#{document_id}/pdf")
        binding.pry
        # Tempfile.new()
      end

      private

      def request_path
        "requests"
      end

      def data_key
        :requests
      end
    end

    # - Instance methods
    def download_pdf
    end
  end
end
