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

      def send_for_signature(document_name:, document:, recipient_data:, additional_data:)
        actions = recipient_data.map do |action_data|
          recipient = action_data.fetch(:recipient)
          {
            role: action_data.fetch(:role),
            recipient_name: recipient.fetch(:name),
            recipient_email: recipient.fetch(:email),
            recipient_phonenumber: recipient[:phone],
            recipient_countrycode: recipient[:country_code],
            verify_recipient: recipient.fetch(:verify, true),
            private_notes: action_data[:private_notes],
            verification_type: action_data.fetch(:verification_type, "EMAIL"),
            action_type: action_data.fetch(:action_type, "SIGN"),
            is_embedded: action_data.fetch(:is_embedded, false ),
          }.compact
        end

        params = {
          file: document,
          data: {
            requests: {
              request_name: document_name,
              actions:,
            }.merge(additional_data)
          }
        }

        body = connection.upload("#{request_path}", params)
        response = build_response(body)
        document_attributes = response.data(:requests)
        ZohoSign::Document.new(**document_attributes)
      end

      def get_embedded_url(request_id, action_id, host)
        body = connection.post("#{request_path}/#{request_id}/actions/#{action_id}/embedtoken?host=#{host}")
        JSON.parse(body)["sign_url"]
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

    def get_embedded_url(for_recipient, host)
      request_id = @attributes.fetch(:request_id)
      action_id = @attributes.fetch(:actions)[for_recipient][:action_id]
      self.class.get_embedded_url(request_id, action_id, host)
    end
  end
end
