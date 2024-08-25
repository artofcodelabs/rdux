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

‼️ JSONB

## 🎮 Usage

### 🚛 Dispatching an action

Definition:

```ruby
def dispatch(action_name, payload, opts = {}, meta: nil)

alias perform dispatch
```

Arguments:
* `action_name` - the name of the service or just the name of the `class` or `module` that implements class or instance method `call` or `up`. Let's call this class/module an **action**.
* `payload` (Hash) - the above mentioned `call` or `up` method receives sanitized `payload` as the first argument. It is saved in DB before `call` or `up` is called. `payload` gets deserialized, hence hash keys get stringified.
* `opts` (Hash) - `call` or `up` method can accept the 2nd argument. `opts` is passed if the 2nd argument is defined. `opts` is useful if you already have a given ActiveRecord object fetched from DB in the controller and you don't want to `find(resource_id)` again in the action. Remember that `payload` should be fully sufficient to perform an **action**. `opts` provides an optimization. There is a helper that facitilates this use case. The implementation is clear enough IMO `(opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }`. `:ars` means ActiveRecords. `opts` are not saved in the DB.
* `meta` (Hash) - additional data saved in the DB along the `action_name`, `payload`, etc. The significant key is the `stream`. It allows to scope a given action to a given stream. It matters when an action is reverted. You can construct a stream based on who owns actions.


Example:

```ruby
Rdux.perform(
  Task::Create, 
  { task: { name: 'Foo bar baz' } }, 
  { ars: { user: current_user } }, 
  meta: {
    stream: { user_id: current_user.id, context: 'foo' }, bar: 'baz'
  }
)
```

### 💪 Action

Example:

```ruby
class Task
  class Create
    def up(payload, opts = {})
      user = opts.dig(:ars, :user) || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        Rdux::Result[ok: true, down_payload: { user_id: user.id, task_id: task.id }, val: { task: }]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end

    def down(payload)
      Delete.up(payload)
    end
  end
end

```

```ruby
class Task
  module Delete
    def self.up(payload)
      user = User.find(payload['user_id'])
      task = user.tasks.find(payload['task_id'])
      task.destroy
      Rdux::Result[true, { task: task.attributes }]
    end
  end
end
```


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
