# frozen_string_literal: true

require_relative "base_record"
require_relative "document"

module ZohoSign
  # Record class to interact with Zoho Sign Templates API
  class Template < ZohoSign::BaseRecord
    class << self
      # @param [String] :template_id Zoho Sign Template ID
      #
      # @param [Hash] :field_data Data used to prefill the document
      # @option :field_data [Hash] :field_text_data
      # @option :field_data [Hash] :field_date_data
      # @option :field_data [Hash] :field_boolean_data
      #
      # @param [Array] :recipient_data Recipient
      # @option :recipient_data [String] :role
      # @option :recipient_data [String] :private_notes
      # @option :recipient_data [String] :action_id
      # @option :recipient_data [String] :action_type
      # @option :recipient_data [String] :verification_type
      # @option :recipient_data [Hash] :recipient
      # @option :recipient [String] :name
      # @option :recipient [String] :email
      # @option :recipient [String] :phone
      # @option :recipient [String] :country_code
      # @option :recipient [Boolean] :verify
      #
      # @param [String] :shared_notes Text to be shown for all recipients
      # @param [Boolean] :quicksend
      #
      # @param [String] :shared_notes Text to be shown for all recipients
      # @param [Boolean] :quicksend
      #
      # @return [Class] ZohoSign::Document instance
      #
      def create_document(template_id:, field_data: {}, recipient_data: [], shared_notes: "", quicksend: true, document_name: nil)
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
            action_id: action_data.fetch(:action_id),
            is_embedded: action_data.fetch(:is_embedded, false)
          }.compact
        end

        params = {
          is_quicksend: quicksend,
          data: {
            templates: {
              request_name: document_name,
              field_data: field_data,
              actions: actions,
              notes: shared_notes
            }.compact
          }.to_json
        }

        body = connection.post("#{request_path}/#{template_id}/createdocument", params.to_query)
        response = build_response(body)
        document_attributes = response.data(:requests)
        ZohoSign::Document.new(**document_attributes)
      end

      private

      def request_path
        "templates"
      end

      def data_key
        :templates
      end
    end

    # - Instance methods
    def create_document(**arguments)
      arguments[:template_id] = @attributes.fetch(:template_id)
      self.class.create_document(**arguments)
    end
  end
end
