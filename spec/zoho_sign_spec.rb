# frozen_string_literal: true

RSpec.describe ZohoSign do
  it "has a version number" do
    expect(ZohoSign::VERSION).not_to be nil
  end

  context "configurable" do
    it "saves the configuration" do
      described_class.config.oauth.client_id = "1000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      described_class.config.oauth.client_secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

      described_class.config.update(
        oauth: {
          access_token: "2000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
          refresh_token: "3000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        }
      )

      expect(described_class.config.values)
        .to eq(
          {
            debug: false,
            oauth: {
              client_id: "1000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
              client_secret: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
              access_token: "2000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
              refresh_token: "3000.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
            },
            api: {
              domain: "https://sign.zoho.com",
              base_path: "/api/v1"
            }
          }
        )
    end
  end
end
