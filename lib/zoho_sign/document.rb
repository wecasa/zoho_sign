# frozen_string_literal: true

require "securerandom"
require_relative "base_record"

module ZohoSign
  # Record class to interact with Zoho Sign Documents API
  class Document < ZohoSign::BaseRecord
    class << self
      def download_pdf(document_id)
        body = connection.download("#{request_path}/#{document_id}/pdf")
        pdf_tmp = Tempfile.new([tempfile_name, ".pdf"], encoding: "ascii-8bit")
        pdf_tmp.write(body)
        pdf_tmp.rewind
        pdf_tmp
      end

      private

      def request_path
        "requests"
      end

      def data_key
        :requests
      end

      def tempfile_name
        SecureRandom.uuid
      end
    end

    def download_pdf
      self.class.download_pdf(@attributes.fetch(:request_id))
    end
  end
end
