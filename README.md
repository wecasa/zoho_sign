# ZohoSign

Simple wrapper around Zoho Sign, using OAuth 2.0 protocol for authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zoho_sign'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install zoho_sign
```

## Usage

### Initialization

Create the following file (or equivalent for your app) and fill it with your credentails.

If you don't have them, follow this official guide: https://www.zoho.com/sign/api/#getting-started

**`config/initializers/zoho_sign.rb`**
```ruby
require "zoho_sign"

ZohoSign.config.debug = true # Default is false. You can enable it to see the requests made by the Gem.

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
```
### Configure regional domain (if applicable)
```ruby
ZohoSign.config.update(
  api: {
    auth_domain: "https://accounts.zoho.eu",
    domain: "https://sign.zoho.eu"
  }
)
```
### How to use `ZohoSign::Template`

Find all templetes:

```ruby
templates = ZohoSign::Template.all
```

Find template by ID:

```ruby
template = ZohoSign::Template.find("12345678900000000")
```

Create document from template:

```ruby
template = ZohoSign::Template.find("12345678900000000")

field_data = {
  field_text_data: {
    full_name: "Homer Simpson",
    address: "742 Evergreen Terrace, Springfield, US"
  }
}

recipient_data = [
  {
    role: "OldOwner",
    action_id: "11111111111111111",
    recipient: {
      name: "Moammar Morris 'Moe' Szyslak",
      email: "moe@springfield.com",
      verify: true
    },
    private_notes: "Please sign this agreement"
  },
  {
    role: "NewOwner",
    action_id: "22222222222222222",
    recipient: {
      name: "Homer Simpson",
      email: "homer.simpson@springfield.com",
      verify: true
    },
    private_notes: "Please sign this agreement"
  }
]

document = ZohoSign::Template.create_document(
  template_id: template.attributes[:template_id],
  field_data: field_data,
  recipient_data: recipient_data,
  document_name: "Agreement (v3)",
  shared_notes: "Agreement to buy Moe's Tavern"
)
```

Download document:

```ruby
document = ZohoSign::Document.find("12345656000000")
document.download_pdf

# OR

ZohoSign::Document.download_pdf("12345656000000")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wecasa/zoho_sign. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/wecasa/zoho_sign/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ZohoSign project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/wecasa/zoho_sign/blob/master/CODE_OF_CONDUCT.md).
