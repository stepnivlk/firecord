# Firecord

![firecord](https://www.swiss-paracord.ch/media/image/product/50/md/firecord-550-acu-digital-25ft-762m~2.jpg)

[![Build Status](https://travis-ci.org/stepnivlk/firecord.svg?branch=master)](https://travis-ci.org/stepnivlk/firecord) [![Ebert](https://ebertapp.io/github/stepnivlk/firecord.svg)](https://ebertapp.io/github/stepnivlk/firecord)

Firecord is an ODM (Object-Document-Mapper) framework for Firebase in Ruby.

Connects to the Firebase REST API, (for now) it's totally synchronous and provides similar API to all those classical Ruby ORMs.

## Usage

You need to download ```credentials.json``` for your Firebase project (Firebase console > Project settings > Service accounts > Generate new private key)

```ruby
require 'firecord'

Firecord.configure do |config|
  config.credentials_file = '/path/to/credentials.json'
end

class Address
  include Firecord::Record

  root_key 'addresses'

  field :name, :string
  field :location, :string
  field :door_number, :integer
  field :timestamps
end

address = Address.new(name: 'home', location: 'Prerov', door_number: 1)
# => #<Address id=nil name="home" location="Prerov" door_number=1 created_at=nil updated_at=nil>

address.save
# => #<Address id="-KdvwtldpM4yVWJfoQIg" name="home" location="Prerov" door_number=1 created_at="2017-02-26T19:44:32+00:00" updated_at=nil>

another_address = Address.find("-KdvwtldpM4yVWJfoQIg")
# => #<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Semice" door_number=2 created_at="2017-02-26T19:33:12+00:00" updated_at=nil>

another_address.door_number = 23
# => 23

another_address.save
# => #<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Semice" door_number=23 created_at="2017-02-26T19:33:12+00:00" updated_at="2017-02-26T19:47:22+00:00">

another_address.update(location: 'Prerov nad Labem')
# => #<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Prerov nad Labem" door_number=23 created_at="2017-02-26T19:33:12+00:00" updated_at="2017-02-26T19:47:22+00:00">

Address.where(name: "not_home", door_number: 23)
# => [#<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Prerov nad Labem" door_number=23 created_at="2017-02-26T19:33:12+00:00" updated_at="2017-02-26T19:47:22+00:00">]

Address.all
# => [#<Address id="-KdvwtldpM4yVWJfoQIg" name="home" location="Prerov" door_number=1 created_at="2017-02-26T19:44:32+00:00" updated_at=nil>, #<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Prerov nad Labem" door_number=23 created_at="2017-02-26T19:33:12+00:00" updated_at="2017-02-26T19:47:22+00:00">]

address.delete
# => true

Address.all
# => [#<Address id="-KgBbL8yedmT88iLmbOE" name="not_home" location="Prerov nad Labem" door_number=23 created_at="2017-02-26T19:33:12+00:00" updated_at="2017-02-26T19:47:22+00:00">]
```

## Current version: 0.2.6
This version adds:
* Basic retypying/checking of invalid assignments, eg: ```address.door_number = '23' #=> 23```.
* ```.where``` method which for now accepts hash and works only for equality, eg: ```Address.where(door_number: 23)```
* Adds proper ```DateTime``` object for ```created_at``` and ```updated_at``` fields
* Adds more 'integration' tests for dummy classes.
* Introduces ```Serializer``` and ```Deserializer``` classes.

### Roadmap to version 0.3.0
- [x] Working timestamps
- [ ] Error handling
- [x] `where` method
- [ ] Test everything
- [x] Better configuration
- [x] Documentation
- [x] Basic type validation
- [ ] Get rid of nil checks in firebase repo
- [ ] Add fields: boolean, datetime, time, date, json
- [ ] Add ```.delete_all``` method
- [ ] Add ```.create``` method

### Future versions
- [ ] Add proper validation
- [ ] Robust persistence state abstraction
- [ ] Some basic associations
- [ ] Define nested documents

#### Version log
##### 0.2.2 codename Spike
This release is not meant to be used by anyone in production. I'm trying to lay down the interface, experiment and learn basics of ORM/ODM by coding and producing something (maybe) usefull. I still need to finalize some functionality, do refactoring and add features.


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

Bug reports and pull requests are welcome on GitHub at https://github.com/stepnivlk/firecord. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

