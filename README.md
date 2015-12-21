# DNSAdapter

[![Build Status](https://travis-ci.org/ValiMail/dns_adapter.svg?branch=master)](https://travis-ci.org/ValiMail/dns_adapter)
[![Test Coverage](https://codeclimate.com/github/ValiMail/dns_adapter/badges/coverage.svg)](https://codeclimate.com/github/ValiMail/dns_adapter)
[![Code Climate](https://codeclimate.com/github/ValiMail/dns_adapter/badges/gpa.svg)](https://codeclimate.com/github/ValiMail/dns_adapter)

An adapter layer for DNS queries that makes it simple to swap in different DNS providers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dns_adapter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dns_adapter

## Usage

DNSAdapter contains a set of useful adapter classes that present a common set of return types and errors for DNS services.  To use the gem, simply instantiate an instance of the desired adapter class.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/dns_adapter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
