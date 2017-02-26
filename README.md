# Firecord

Firecord is an ODM (Object-Document-Mapper) framework for FireBase in Ruby.
Provides similar API to all those classical Ruby ORM, except the fact that your data are stored in the cloud.


## Usage

```ruby
require 'firecord'

Firecord.configure do |config|
  credentials_file: '/path/to/credentials.json'
end

class Address
  include Firecord::Record

  root_key 'addresses'

  field :name, :string
  field :location, :string
  field :door_number, :integer
  field :timestamps
end

address = Address.new(name: 'home', location: 'Prerov vole', door_number: 1)
# => #<Address id=nil name="home" location="Prerov vole" door_number=1 created_at=nil updated_at=nil>

address.save
# => #<Address id="-KdvwtldpM4yVWJfoQIg" name="home" location="Prerov vole" door_number=1 created_at="2017-02-26T19:44:32+00:00" updated_at=nil>

same_address = Address.find("-KdvwtldpM4yVWJfoQIg")
# => #<Address id="-KdvwtldpM4yVWJfoQIg" name="home" location="Prerov vole" door_number=1 created_at="2017-02-26T19:44:32+00:00" updated_at=nil>

same_address.door_number = 23
# => 23

same_address.save
#<Address id=-KdvwtldpM4yVWJfoQIg name="home" location="Prerov vole" door_number=23 created_at="2017-02-26T19:44:32+00:00" updated_at="2017-02-26T19:47:22+00:00">

same_address.update(location: 'Prerov nad Labem vole')
# => #<Address id=-KdvwtldpM4yVWJfoQIg name="home" location="Prerov nad Labem vole" door_number=23 created_at="2017-02-26T19:44:32+00:00" updated_at="2017-02-26T19:48:20+00:00">

Address.all
# => [#<Address id=-KdvwtldpM4yVWJfoQIg name="home" location="Prerov nad Labem vole" door_number=23 created_at="2017-02-26T19:44:32+00:00" updated_at="2017-02-26T19:48:20+00:00">]

address.delete
# => true

Address.all
# => []
```

## Current version: 0.2.0 codename Spike
This release is not meant to be used by anyone in production. I'm trying to laid down the interface, experiment and learn basics of ORM/ODM by coding and producing something (maybe) usefull. I still need to finalize some functionality, do refactoring and add features.

### What I'm working on now
- [ ] Add proper validation
- [ ] Robust persistence state abstraction
- [ ] Better configuration
- [ ] Some basic associations
- [ ] Documentation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firecord'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firecord
    

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Tomas Koutsky/firecord. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

