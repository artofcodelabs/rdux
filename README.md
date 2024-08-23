# Rdux

![Logo](docs/logo.webp)

Rdux is a Rails plugin.  

This library provides your application with audit logs.  
Rdux gives the Rails app an ability to store in the database sanitized input data (**action name** ➕ **payload**) as the `Rdux::Action`.  
**Action** is a PORO whose `call` or `up` method takes the **payload** as the argument.   
Use `meta` to save additional data like `current_user.id`, etc.  
Use `up_result` to store DB changes, IDs of created records, responses from 3rd parties etc.  

Rdux is a minimal take on event sourcing.

Rdux provides support for reverting actions 👉 down  

organically introduces 2 layers: actions and queries  

unifies the type of payload 👉 no more with_indifferent_access  

saves failed and nested actions  

~It makes it easy to trace when, where, why, and how your application's state changed.

## 📲 Instalation

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

Then instal and run migrations:

```bash
$ bin/rails rdux:install:migrations
$ bin/rails db:migrate
```

## 🎮 Usage

### 🚛 Dispatching an action

Definition:

```ruby
def dispatch(action_name, payload, opts = {}, meta: nil)
```

Arguments:
* `action_name` -
* `payload` -
* `opts` -
* `meta` -


Example:

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

### Action

...


### Returned `struct`

Definition:

```ruby
module Rdux
  Result = Struct.new(:ok, :down_payload, :val, :up_result, :save, :after_save, :nested, :action) do
    def val
      self[:val] || down_payload
    end

    def save_failed?
      ok == false && save
    end
  end
end
```

Arguments:
* `ok` - 
* ...

Example:

```ruby
Rdux::Result[true, { activity: activity }]
```

## 📈 Flow diagram

![Flow Diagram](docs/flow.png)


## Test

### Setup

```bash
$ cd test/dummy
$ DB=all bin/rails db:create
$ DB=all bin/rails db:prepare
$ cd ../..
```

### Run tests

```bash
$ DB=postgres bin/rails test
$ DB=sqlite bin/rails test
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
