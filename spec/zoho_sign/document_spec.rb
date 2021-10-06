# frozen_string_literal: true

RSpec.describe ZohoSign::Document do
  let!(:refresh_token_stub) do
    stub_request(:post, %r{^https://accounts\.zoho\.com/oauth/v2/token\?.*grant_type=refresh_token.*})
      .to_return(
        status: 200,
        body: {
          access_token: ENV["ZOHO_SIGN_ACCESS_TOKEN"],
          refresh_token: ENV["ZOHO_SIGN_REFRESH_TOKEN"],
          expires_in: 3600
        }.to_json
      )
  end

  before do
    ZohoSign.config.update(
      oauth: {
        client_id: ENV["ZOHO_SIGN_CLIENT_ID"],
        client_secret: ENV["ZOHO_SIGN_CLIENT_SECRET"],
        access_token: ENV["ZOHO_SIGN_ACCESS_TOKEN"],
        refresh_token: ENV["ZOHO_SIGN_REFRESH_TOKEN"]
      }
    )

    params = ZohoSign::Auth.refresh_token(ENV["ZOHO_SIGN_REFRESH_TOKEN"])
    ZohoSign.config.connection = params
  end

  describe ".download_pdf" do
    let(:document_id) { Faker::Number.number(digits: 7).to_s }
    let!(:download_pdf_from_template_stub) do
      body = JSON.parse(File.read("spec/webmocks/document_pdf.json"), symbolize_names: true)
      stub_request(:get, "https://sign.zoho.com/api/v1/requests/#{document_id}/pdf")
        .with(
          headers: {
            "Authorization" => /Zoho-oauthtoken .*/,
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(
          status: 200,
          body: body.to_json,
          headers: {
            "Content-Type" => "application/pdf",
            "charset" => "UTF-8"
          }
        )
    end

    it "calls zoho sign template api and returns an instance of Tempfile" do
      object = described_class.download_pdf(document_id)
      expect(object).to be_kind_of(Tempfile)
      expect(object.size).not_to be_nil
      expect(download_pdf_from_template_stub).to have_been_requested
    end
  end
end
