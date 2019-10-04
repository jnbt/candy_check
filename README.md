# candy_check

[![Gem Version](https://badge.fury.io/rb/candy_check.svg)](http://badge.fury.io/rb/candy_check)
[![Build Status](https://travis-ci.org/jnbt/candy_check.svg?branch=master)](https://travis-ci.org/jnbt/candy_check)
[![Coverage Status](https://coveralls.io/repos/jnbt/candy_check/badge.svg?branch=master)](https://coveralls.io/r/jnbt/candy_check?branch=master)
[![Code Climate](https://codeclimate.com/github/jnbt/candy_check/badges/gpa.svg)](https://codeclimate.com/github/jnbt/candy_check)
[![Gemnasium](https://img.shields.io/gemnasium/jnbt/candy_check.svg?style=flat)](https://gemnasium.com/jnbt/candy_check)
[![Inline docs](http://inch-ci.org/github/jnbt/candy_check.svg?branch=master)](http://inch-ci.org/github/jnbt/candy_check)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/github/jnbt/candy_check/master)

Check and verify in-app receipts from the AppStore and the PlayStore.

## Installation

```Bash
gem install candy_check
```

## Introduction

This gem tries to simplify the process of server-side in-app purchase and subscription validation for Apple's AppStore and Google's PlayStore.

### AppStore

If you have set up an iOS app and its in-app items correctly and the in-app store is working your app should receive a
`SKPaymentTransaction`. Currently this gem assumes that you use the old [`transactionReceipt`](https://developer.apple.com/library/ios/documentation/StoreKit/Reference/SKPaymentTransaction_Class/index.html#//apple_ref/occ/instp/SKPaymentTransaction/transactionReceipt)
which is returned per transaction. The `transactionReceipt` is a base64 encoded binary blob which you should send to your
server for the validation process.

To validate a receipt one normally has to choose between the two different endpoints "production" and "sandbox" which are provided from
[Apple](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1).
During development your app gets receipts from the sandbox while when released from the production system. A special case is the
review process because the review team uses the release version of your app but processes payment against the sandbox.
Only for receipts that contain auto-renewable subscriptions you need your app's shared secret (a hexadecimal string),

Please keep in mind that you have to use test user account from the iTunes connect portal to test in-app purchases during
your app's development.

### PlayStore

Google's PlayStore has different kind of server-to-server API to check purchases and requires that you register a so
called "[service account](https://developers.google.com/accounts/docs/OAuth2ServiceAccount)". You have to register a
new account by yourself, export the generated certificate file and grant the correct permissions to the account for
your app using the [Google Developer Console](https://console.developers.google.com).

Further more this gem uses the [official Ruby SDK](https://github.com/google/google-api-ruby-client) for the API interactions
which suggest to use a locally cached service discovery. If you don't omit the `cache_file` configuration this is done
automatically.

If you have set up the Android app correctly you should get a [`purchaseToken`](http://developer.android.com/google/play/billing/billing_reference.html#getBuyIntent) per purchased item. You should use this string in combination with `packageName` and `productId`
to verify the purchase.

## Usage

### AppStore

First you should initialize a verifier instance for your application:

```ruby
config = CandyCheck::AppStore::Config.new(
  environment: :production # or :sandbox
)
verifier = CandyCheck::AppStore::Verifier.new(config)
```

For the AppStore the client should deliver a base64 encoded receipt data string
which can be verified by using the following call:

```ruby
verifier.verify(your_receipt_data) # => Receipt or VerificationFailure
# or by using a shared secret for subscriptions
verifier.verify(your_receipt_data, your_secret)
```

Please see the class documenations [`CandyCheck::AppStore::Receipt`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/Receipt) and [`CandyCheck::AppStore::VerificationFailure`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/VerificationFailure) for further details about the responses.

For **subscription verification**, Apple also returns a list of the user's purchases. Essentially, this is a collection of receipts. To verify a subscription, do the following:

```ruby
# ... create your verifier as above
verifier.verify_subscription(your_receipt_data, your_secret) # => ReceiptCollection or VerificationFailure
```

Please see the class documentation for [`CandyCheck::AppStore::ReceiptCollection`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/AppStore/ReceiptCollection) for further details.

### PlayStore

#### Authorization

First we have to build an `authorization` object:

```ruby
authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: File.open("path/to/key.json"),
  scope: "https://www.googleapis.com/auth/androidpublisher",
)
```

> **Note:** More info about the `authorization` object can be found [here](https://github.com/googleapis/google-api-ruby-client#passing-authorization-to-requests)

#### Building a verifier

With the `authorization` object in place, we can build a verifier:

```ruby
verifier = CandyCheck::PlayStore::Verifier.new(auth: authorization)
```

> Tip: If you need to verify against multiple Google Service Accounts, just instantiate another verifier with different credentials.

#### Verifying product purchases

This `verifier` can be used to verify product purchases in the PlayStore, all you need to do is to pass the `package_name`, `product_id` and `token` of the product purchase you want to verify:

```ruby
result = verifier.verify(package_name, product_id, token) # => ProductPurchase or VerificationFailure
```

On success this will return an instance of `CandyCheck::Playstore::ProductPurchases::ProductPurchase`, which is a wrapper for the raw [google-api-ruby-client](https://github.com/googleapis/google-api-ruby-client) data, but additionally provides some handy convenience methods for the non-intuitive integer attributes `consumption_state`, `purchase_state`, `purchase_time_millis`:

```ruby
# Raw API call attributes
result.consumption_state    # => 0 || 1
result.developer_payload    # => "..."
result.kind                 # => "androidpublisher#productPurchase"
result.order_id             # => "<some ID>"
result.purchase_state       # => 0 || 1 || 2
result.purchase_time_millis # => Integer (Unix timestamp)

# convenience methods
result.valid?       # => true if product was purchased (purchase_state == 0)
result.consumed?    # => true if product has been consumed (consumption_state == 1)
result.purchased_at # => DateTime
```

Please see the class documentations [`CandyCheck::PlayStore::Receipt`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/PlayStore/Receipt) and [`CandyCheck::PlayStore::VerificationFailure`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/PlayStore/VerificationFailure) for further details about the responses.

#### Verifying subscriptions

In order to **verify a subscription** from the Play Store, do the following:

```ruby
verifier.verify_subscription(package, subscription_id, token) # => SubscriptionPurchase or VerificationFailure
```

Please see documenation for [`CandyCheck::PlayStore::Subscription`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/PlayStore/Subscription) for further details.

## CLI

This gem ships with an executable to verify in-app purchases directly from your terminal:

### AppStore

You only need to specify the base64 encoded receipt:

```bash
$ candy_check app_store RECEIPT_DATA
```

See all options:

```bash
$ candy_check help app_store
```

### PlayStore

For the PlayStore you need to specify at least the issuer, the key file, your package name, the product and the actual
purchase token:

```bash
$ candy_check play_store PACKAGE PRODUCT_ID TOKEN --issuer=ISSUER --key-file=KEY_FILE
```

See all options:

```bash
$ candy_check help play_store
```


## Todos

* Allow using the combined StoreKit receipt data
* Find a ways to run integration tests

## Bugs and Issues

Please submit them here https://github.com/jnbt/candy_check/issues

## Test

Simple run

```Bash
rake
```

## Copyright

Copyright &copy; 2016 Jonas Thiel. See LICENSE.txt for details.
