# frozen_string_literal: true

RSpec.describe ZohoSign::Template do
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
    # ZohoSign.config.debug = true

    ZohoSign.config.update(
      oauth: {
        client_id: ENV["ZOHO_SIGN_CLIENT_ID"],
        client_secret: ENV["ZOHO_SIGN_CLIENT_SECRET"],
        access_token: ENV["ZOHO_SIGN_ACCESS_TOKEN"],
        refresh_token: ENV["ZOHO_SIGN_REFRESH_TOKEN"]
      }
    )

    ZohoSign.config.connection = {
      access_token: ZohoSign.config.oauth.access_token,
      refresh_token: ZohoSign.config.oauth.refresh_token,
      expires_in: 3600
    }
  end

  describe ".all" do
    let!(:get_templates_stub) do
      body = JSON.parse(File.read("spec/webmocks/templates.json"), symbolize_names: true)

      stub_request(:get, %r{^https://sign\.zoho\.com/api/v1/templates(\?.*)?})
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
            "Content-Type" => "application/json",
            "charset" => "UTF-8"
          }
        )
    end

    let(:template_id) { Faker::Number.number(digits: 17).to_s }

    it "calls zoho sign template api and returns an instance of current class" do
      object = described_class.all
      expect(object).to be_kind_of(Array)
      expect(object.size).to eq(1)
      expect(object.first).to be_kind_of(described_class)
      expect(get_templates_stub).to have_been_requested
    end
  end

  describe ".find" do
    let!(:get_template_stub) do
      body = JSON.parse(File.read("spec/webmocks/template.json"), symbolize_names: true)
      body[:templates][:template_id] = template_id

      stub_request(:get, "https://sign.zoho.com/api/v1/templates/#{template_id}")
        .with(
          headers: {
            "Authorization" => "Zoho-oauthtoken #{ENV["ZOHO_SIGN_ACCESS_TOKEN"]}",
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(
          status: 200,
          body: body.to_json,
          headers: {
            "Content-Type" => "application/json",
            "charset" => "UTF-8"
          }
        )
    end

    let(:template_id) { Faker::Number.number(digits: 17).to_s }

    it "calls zoho sign template api and returns an instance of current class" do
      object = described_class.find(template_id)
      expect(object).to be_kind_of(described_class)
      expect(object.attributes[:template_id]).to eq(template_id)
      expect(get_template_stub).to have_been_requested
    end

    context "when Zoho Sign returns HTML with error" do
      before do
        ZohoSign.config.update(
          oauth: {
            client_id: ENV["ZOHO_SIGN_CLIENT_ID"],
            client_secret: ENV["ZOHO_SIGN_CLIENT_SECRET"],
            access_token: "Invalid Token",
            refresh_token: ENV["ZOHO_SIGN_REFRESH_TOKEN"]
          }
        )

        ZohoSign.config.connection = {
          access_token: "Invalid Token",
          refresh_token: ENV["ZOHO_SIGN_REFRESH_TOKEN"],
          expires_in: 3600
        }
      end

      let!(:get_template_stub_error) do
        stub_request(:get, "https://sign.zoho.com/api/v1/templates/#{template_id}")
          .with(
            headers: {
              "Authorization" => "Zoho-oauthtoken Invalid Token",
              "Content-Type" => "application/json"
            }
          )
          .to_return(
            status: 401,
            body: File.read("spec/webmocks/document_error.html"),
            headers: { "Content-Type" => "text/html" }
          )
      end

      it "refreshes token and returns an instance of current class" do
        described_class.find(template_id)
        expect(get_template_stub_error).to have_been_requested
        expect(refresh_token_stub).to have_been_requested
        expect(get_template_stub).to have_been_requested
      end
    end
  end

  describe ".create_document" do
    let!(:create_document_from_template_stub) do
      body = JSON.parse(File.read("spec/webmocks/document_from_template.json"), symbolize_names: true)

      stub_request(:post, "https://sign.zoho.com/api/v1/templates/#{template_id}/createdocument")
        .with(
          headers: {
            "Authorization" => /Zoho-oauthtoken .*/,
            "Content-Type" => "application/json"
          }
        )
        .to_return(
          status: 200,
          body: body.to_json,
          headers: {
            "Content-Type" => "application/json",
            "charset" => "UTF-8"
          }
        )
    end

    let(:template_id) { Faker::Number.number(digits: 17).to_s }
    let(:recipient_name) { Faker::TvShows::Simpsons.character }
    let(:recipient_email) { Faker::Internet.email(name: recipient_name) }
    let(:recipient_action_id) { Faker::Number.number(digits: 17).to_s }

    it "calls zoho sign template api and returns an instance of current class" do
      field_data = {
        field_text_data: {
          customer_first_name: recipient_name
        }
      }

      recipient_data = [
        {
          role: "Customer",
          action_id: recipient_action_id,
          recipient: {
            name: recipient_name,
            email: recipient_email,
            verify: false
          },
          private_notes: "Please sign this agreement"
        }
      ]

      object = described_class.create_document(
        template_id: template_id,
        field_data: field_data,
        recipient_data: recipient_data,
        shared_notes: "Agreement to buy Moe's Tavern"
      )
      expect(object).to be_kind_of(ZohoSign::Document)
      expect(create_document_from_template_stub).to have_been_requested
    end
  end

  describe "#create_document" do
    let!(:create_document_from_template_stub) do
      body = JSON.parse(File.read("spec/webmocks/document_from_template.json"), symbolize_names: true)

      stub_request(:post, "https://sign.zoho.com/api/v1/templates/#{template_id}/createdocument")
        .with(
          headers: {
            "Authorization" => /Zoho-oauthtoken .*/,
            "Content-Type" => "application/json"
          }
        )
        .to_return(
          status: 200,
          body: body.to_json,
          headers: {
            "Content-Type" => "application/json",
            "charset" => "UTF-8"
          }
        )
    end

    let(:template_id) { Faker::Number.number(digits: 17).to_s }
    let(:template) { described_class.new(template_id: template_id) }
    let(:recipient_name) { Faker::TvShows::Simpsons.character }
    let(:recipient_email) { Faker::Internet.email(name: recipient_name) }
    let(:recipient_action_id) { Faker::Number.number(digits: 17).to_s }

    it "calls zoho sign template api and returns an instance of current class" do
      field_data = {
        field_text_data: {
          customer_first_name: recipient_name
        }
      }

      recipient_data = [
        {
          role: "Customer",
          action_id: recipient_action_id,
          recipient: {
            name: recipient_name,
            email: recipient_email,
            verify: false
          },
          private_notes: "Please sign this agreement"
        }
      ]

      object = template.create_document(
        field_data: field_data,
        recipient_data: recipient_data,
        shared_notes: "Agreement to buy Moe's Tavern"
      )
      expect(object).to be_kind_of(ZohoSign::Document)
      expect(create_document_from_template_stub).to have_been_requested
    end
  end
end
