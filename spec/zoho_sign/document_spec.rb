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
      stub_request(:get, "https://sign.zoho.com/api/v1/requests/#{document_id}/pdf")
        .with(
          headers: {
            "Authorization" => /Zoho-oauthtoken .*/,
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(
          status: 200,
          body: File.read("spec/webmocks/document.pdf"),
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

  describe ".send_for_signature" do
    let!(:create_document_stub) do
      body = JSON.parse(File.read("spec/webmocks/documents/create_document_success_response.json"), symbolize_names: true)

      stub_request(:post, "https://sign.zoho.com/api/v1/requests")
        .with{ |request|
          body_keys = URI.decode_www_form(request.body).to_h.keys
          expected_keys = %w[data[requests][actions][] data[requests][request_name] file]
          body_keys == expected_keys
        }
        .to_return(
          status: 200,
          body: body.to_json,
          headers: {
            "Content-Type" => "application/json",
            "charset" => "UTF-8"
          }
        )
    end

    it 'should send for signature' do
      document = Faraday::UploadIO.new("spec/webmocks/document.pdf", "application/pdf")
      recipient_data = []
      additional_data = {}

      object = described_class.send_for_signature(
        document_name: "test",
        document:,
        recipient_data:,
        additional_data:
      )

      expect(object).to be_kind_of(ZohoSign::Document)
      expect(create_document_stub).to have_been_requested
    end
  end

  describe "#get_embedded_url" do
    let(:sign_url) { Faker::Internet.url }
    let!(:patch_request_stub) {
      stub_request(:post, "https://sign.zoho.com/api/v1/requests/48425000000037091/actions/48425000000037116/embedtoken?host=https://example.com").
        with(
          headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>'Zoho-oauthtoken 0000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
            'Content-Type'=>'application/x-www-form-urlencoded',
            'User-Agent'=>'Faraday v1.10.3'
          }).
        to_return(status: 200, body: {sign_url: }.to_json, headers: {})
    }

    it 'should get embedded url for signing' do
      data = JSON.parse(File.read("spec/webmocks/documents/create_document_success_response.json"), symbolize_names: true)
      document = ZohoSign::Document.new(**data[:requests])
      for_recipient = 0
      host = "https://example.com"
      expect(document.get_embedded_url(for_recipient, host)).to eq(sign_url)
    end
  end

end
