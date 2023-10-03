# frozen_string_literal: true

RSpec.describe ZohoSign do
  it "has a version number" do
    expect(ZohoSign::VERSION).not_to be nil
  end

  context "configurable" do
    it "saves the configuration" do
      described_class.config.debug = false
      described_class.config.connection = nil
      described_class.config.oauth.client_id = "1000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      described_class.config.oauth.client_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      described_class.config.oauth.redirect_uri = "http://example.com"

      described_class.config.update(
        oauth: {
          access_token: "2000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
          refresh_token: "3000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        }
      )

      expect(described_class.config.values[:debug]).to eq(false)
      expect(described_class.config.values[:oauth][:client_id]).to eq("1000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
      expect(described_class.config.values[:oauth][:client_secret]).to eq("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
      expect(described_class.config.values[:oauth][:access_token]).to eq("2000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
      expect(described_class.config.values[:oauth][:refresh_token]).to eq("3000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
      expect(described_class.config.values[:oauth][:redirect_uri]).to eq("http://example.com")
      expect(described_class.config.values[:connection]).to eq(nil)
      expect(described_class.config.values[:api][:auth_domain]).to eq("https://accounts.zoho.com")
      expect(described_class.config.values[:api][:domain]).to eq("https://sign.zoho.com")
      expect(described_class.config.values[:api][:base_path]).to eq("/api/v1")
    end
  end
end
