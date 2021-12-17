# How to create a new release

## Step 1: Update `CHANGELOG.md`

The step 1 is to make sure the `CHANGELOG.md` is up-to-date. If is not up-to-date
please update the missing changes.

## Step 2: Prepare the release

Note: This steps needs to be performed in the `main` branch. Remember to have a up-to-date repo.

First open the `lib/zoho_sign/version.rb` file and update the `VERSION` constant.

We are following "[Semantic Versioning v2](https://semver.org/spec/v2.0.0.html)" conventions.

## Step 3: Setup your environment

First of all make sure you have the file `~/.gem/credentials` with this content:

```yml
---
:rubygems_api_key: $RUBYGEM_API_KEY
:github: $GITHUB_TOKEN_API_KEY
```

You can get your `$RUBYGEM_API_KEY` from your RubyGems.org account.
You can get your `$GITHUB_TOKEN_API_KEY` from your GitHub.com account. Instructions [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

## Step 4: Publish new gem version in GitHub Package Registry

Now last step run this terminal commands:

```bash
gem build *.gemspec
gem push --KEY github --host https://$GITHUB_USER:$GITHUB_TOKEN_API_KEY@rubygems.pkg.github.com/wecasa *.gem
```

- `$GITHUB_USER` -> example `wakematta`
- `$GITHUB_TOKEN_API_KEY` -> Instructions [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

## Step 5: Publish new gem version in RubyGems.org

Now you can run this terminal command:

```bash
gem bump --release --push --tag --version '$NEW_RELEASE_VERSION' --message ':arrow_up: Prepare release v%{version} %{skip_ci}'
```

Remember that `$NEW_RELEASE_VERSION` needs to be the same as the one in `lib/zoho_sign/version.rb`.

You can add `--pretend` to the command, to make sure there is no erros. Before doing it for real.
