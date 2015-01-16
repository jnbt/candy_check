candy_check
===========

[![Gem Version](https://badge.fury.io/rb/candy_check.svg)](http://badge.fury.io/rb/candy_check)
[![Build Status](https://travis-ci.org/jnbt/candy_check.svg?branch=master)](https://travis-ci.org/jnbt/candy_check)
[![Coverage Status](https://coveralls.io/repos/jnbt/candy_check/badge.svg?branch=master)](https://coveralls.io/r/jnbt/candy_check?branch=master)
[![Inline docs](http://inch-ci.org/github/jnbt/candy_check.svg?branch=master)](http://inch-ci.org/github/jnbt/candy_check)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg?style=flat)](http://www.rubydoc.info/github/jnbt/candy_check/master)

Check and verify in-app receipts

Installation
------------

```Bash
gem install candy_check
```

Configuration
-------------

You can configure the gem on a module level. See the following example:

```ruby
CandyCheck.configure do |config|
  config.app_store do |app_store|
    app_store.verification_url = 'https://sandbox.itunes.apple.com/verifyReceipt'
    # or for production
    # app_store.verification_url = 'https://buy.itunes.apple.com/verifyReceipt"'
  end
end
```

Usage
-----

For the AppStore the client should deliver a base64 encoded receipt data string
which can be verified by using the following call:

```ruby
CandyCheck::AppStore.verify(your_receipt_data) # => Receipt or Failure
# or by using a shared secret for subscriptions
CandyCheck::AppStore.verify(your_receipt_data, your_secret)
```

Todos
-----

* Support Google PlayStore tokens

Bugs and Issues
---------------

Please submit them here https://github.com/jnbt/candy_check/issues

Test
----

Simple run

```Bash
rake
```

Copyright
---------

Copyright (c) 2015 Jonas Thiel. See LICENSE.txt for details.