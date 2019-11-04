# Migration Guide from v0.1.x to v0.2.0

Due to changes in the PlayStore API, Candy Check needed to introduce some breaking changes in version `0.2.0`.

To adapt your old implementation to these changes, follow the steps below:

## Authorization

First we have to change, how our verifier authenticates against the Google API.

Change code like this

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
authorization = CandyCheck::PlayStore.authorization("/path/to/key.json")
verifier = CandyCheck::PlayStore::Verifier.new(auth: authorization)
```

If you're not sure how to get a `.json` key file, follow this part of the [`README`](/README.md#getting-the-json-key-file).

If you need other means of authentication follow this part of the [`README`](http://localhost:6419/README.md#building-an-authorization-object).

## Verifying Purchases

To be more descriptive and consistent with the PlayStore API, the verifier got a new signature and return values have been adapted accordingly.

### Verifying Product Purchases

Change all occurences of

```ruby
# < v0.2.0
verifier.verify("my-package-name", "my product id", "my token")
# => Receipt or VerificationFailure
```

to

```ruby
# v0.2.0
verifier.verify_product_purchase(
  package_name: "my-package-name",
  product_id: "my product id",
  token: "my token"
)
# => ProductPurchase or VerificationFailure
```

*NOTE:* Take a closer look at the possible return values: `CandyCheck::PlayStore::Receipt` was moved to `CandyCheck::PlayStore::ProductPurchases::ProductPurchase`. In case you're matching at the class name of the result, please adapt your code accordingly.

## Verifying Subscription Purchases

Change all occurences of

```ruby
# < v0.2.0
verifier.verify_subscription("my-package-name", "my-subscription-id", "my-token")
# => Subscription or VerificationFailure
```

to

```ruby
# v0.2.0
verifier.verify_subscription_purchase(
  package_name: "my-package-name",
  subscription_id: "my-subscription-id",
  token: "my-token"
)
# => SubscriptionPurchase or VerificationFailure
```

*NOTE:* Again take a closer look at the possible return values: `CandyCheck::PlayStore::Subscription` was moved to `CandyCheck::PlayStore::SubscriptionPurchases::SubscriptionPurchase`. In case you're matching at the class name of the result, please adapt your code accordingly.
