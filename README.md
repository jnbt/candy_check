# candy_check

[![Gem Version](https://badge.fury.io/rb/candy_check.svg)](http://badge.fury.io/rb/candy_check)
[![Build Status](https://travis-ci.org/jnbt/candy_check.svg?branch=master)](https://travis-ci.org/jnbt/candy_check)
[![Coverage Status](https://coveralls.io/repos/jnbt/candy_check/badge.svg?branch=master)](https://coveralls.io/r/jnbt/candy_check?branch=master)
[![Inline docs](http://inch-ci.org/github/jnbt/candy_check.svg?branch=master)](http://inch-ci.org/github/jnbt/candy_check)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/github/jnbt/candy_check/master)

Check and verify in-app receipts from the AppStore and the PlayStore.

## Installation

```Bash
gem install candy_check
```

## Introduction

This gem tries to simplify the process of server-side in-app purchase validation for Apple's AppStore and
Google's PlayStore.

### AppStore

If you have set up an iOS app and it's in-app items correctly and the in-app store is working your app should receive a
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

### PlayStore

First initialize and **boot** a verifier instance for your application. This loads the API discovery and 
fetches the needed OAuth access token. When configuring a `cache_file` the discovery is loaded (or dumped) to 
this file:

```ruby
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

For the PlayStore your client should deliver the purchases token, package name and product id:

```ruby
verifier.verify(package, product_id, token) # => Receipt or VerificationFailure
```

Please see the class documenations [`CandyCheck::PlayStore::Receipt`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/PlayStore/Receipt) and [`CandyCheck::PlayStore::VerificationFailure`](http://www.rubydoc.info/github/jnbt/candy_check/master/CandyCheck/PlayStore/VerificationFailure) for further details about the responses.


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

Copyright &copy; 2015 Jonas Thiel. See LICENSE.txt for details.