# Rdux
Minimal take on event sourcing.

## Usage

```bash
$ bin/rails rdux:install:migrations
$ bin/rails db:migrate
```

### Code structure

### Dispatch action

```ruby
Rdux.perform(
  Activity::Stop,
  { activity_id: current_activity.id },
  { activity: current_activity },
  meta: {
    stream: { user_id: 123, context: 'foo' }, bar: 'baz'
  }
)
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rdux'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rdux
```

## Test

```bash
$ DB=postgres bin/test
$ DB=sqlite bin/test
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
