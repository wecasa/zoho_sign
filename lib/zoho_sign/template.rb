# frozen_string_literal: true

require "zoho_sign/base_record"

module ZohoSign
  class Template < ZohoSign::BaseRecord
    class << self
      private

      def request_path
        "templates"
      end

      def data_key
        :templates
      end
    end

    def initialize(**attributes)
      @attributes = attributes
    end
  end
end
