# Migration Guide from v0.1.x to v0.2.0

Due to changes in the `Google API`, `Candy Check` needed to introduce some breaking changes in version `0.2.0`.

To adapt your old implementation to these changes, follow the steps below:

## Authorization

Change the old authorization config from something like

```ruby
# < v0.2.0
config = CandyCheck::PlayStore::Config.new(
  application_name: 'YourApplication',
  application_version: '1.0',
  issuer: 'abcdefg@developer.gserviceaccount.com',
  key_file: 'local/google.p12',
  key_secret: 'notasecret',
  cache_file: 'tmp/candy_check_play_store_cache'
)
verifier = CandyCheck::PlayStore::Verifier.new(config)
verifier.boot!
```

to

```ruby
# v0.2.0
authorization = CandyCheck::PlayStore.authorization("/path/to/key.json") }
verifier = CandyCheck::PlayStore::Verifier.new(auth: authorization)
```

If you're not sure how to get a `.json` key file, follow the [`README`](/README.md#getting-the-json-key-file).

## Verifying Product Purchases
