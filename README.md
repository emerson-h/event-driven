# EventDriven

Provides a basic ruby port of Symfony's EventDispatacher component.  

Eventing allows connecting two components of an application without coupling between them.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event_driven'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_driven

## Usage

Basic event usage:

```ruby
  # Creating a custom event class
  class PartyInvitation < EventDriven::Event
    attr_reader :message
    
    def initialize(message)
      @message = message
    end
  end
  
  # Any ruby object that implements #call can be used as a listener  
  handler = -> (event, event_name) do
    puts "#{event_name} - message #{event.message}" 
  end
  
  # Creating a dispatcher
  dispatcher = EventDriven::Dispatcher.new
  
  # Add a listener to any event name
  dispatcher.add_listener(event_name: :party_time, listener: handler)
  
  # Fire an event to let other parts of the system know it happened
  
  party_anouncement = PartyInvitation.new("It's party time!")
  
  dispatcher.dispatch(event_name: :party_time, event: party_anouncement)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/emerson-h/event_driven.

