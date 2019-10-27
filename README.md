# Glare

Ruby gem to interact with CloudFlare API v4

## Build Status

[![Build Status](https://travis-ci.org/peertransfer/glare.svg?branch=master)](https://travis-ci.org/peertransfer/glare)
[![Coverage Status](https://coveralls.io/repos/github/peertransfer/glare/badge.svg?branch=master)](https://coveralls.io/github/peertransfer/glare?branch=master)
[![Code Climate](https://codeclimate.com/github/peertransfer/glare/badges/gpa.svg)](https://codeclimate.com/github/peertransfer/glare)
[![Known Vulnerabilities](https://snyk.io/test/github/peertransfer/glare/badge.svg)](https://snyk.io/test/github/peertransfer/glare)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'glare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glare

## Usage

In order to configure credentials used to interact with Cloudflare API you will need to setup the following environment variables:

- `CF_EMAIL`: Email used to create a Cloudflare account
- `CF_AUTH_KEY`: Auth key of the given user

Additionally, you can set other environment variables:

- `CF_DEBUG`: Set to `1` to enable HTTP requests' debug

### Create/update DNS record

```ruby
require 'glare'

Glare.register('example.domain.com', 'destination.com' ,'CNAME')
```

Where:
  - `example.domain.com`: Name of the record to create
  - `destination.com`: Name(s) of the values of the record
  - `CNAME`: Type of the DNS record

### Delete DNS record

```ruby
require 'glare'

Glare.deregister('example.domain.com', 'CNAME')
```

Where:
  - `example.domain.com`: Name of the record to destroy
  - `CNAME`: Type of the DNS record

### Resolve DNS record

```ruby
require 'glare'

Glare.resolve('example.domain.com', 'CNAME')
```

Where:
  - `example.domain.com`: Name of the record to resolve
  - `CNAME`: Type of the DNS record

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/peertransfer/glare/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
