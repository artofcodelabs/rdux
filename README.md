# Rdux - A Minimal Event Sourcing Plugin for Rails

![Logo](docs/logo.webp)

Rdux is a lightweight, minimalistic Rails plugin designed to introduce event sourcing and audit logging capabilities to your Rails application. With Rdux, you can efficiently track and store the history of actions performed within your app, offering transparency and traceability for key processes.

**Key Features**

* **Audit Logging** 👉 Rdux stores sanitized input data, the name of module or class (action) responsible for processing them, processing results, and additional metadata in the database.
* **Model Representation** 👉 Before action is executed it gets stored in the database through the `Rdux::Action` model. `Rdux::Action` is converted to the `Rdux::FailedAction` when it fails. These models can be nested, allowing for complex action structures.
* **Revert and Retry** 👉 `Rdux::Action` can be reverted or retried.

Rdux is designed to integrate seamlessly with your existing Rails application, offering a straightforward and powerful solution for managing and auditing key actions.

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

Then install and run migrations:

```bash
$ bin/rails rdux:install:migrations
$ bin/rails db:migrate
```

⚠️ Note: Rdux uses `JSONB` datatype instead of `text` for Postgres.

## 🎮 Usage

### 🚛 Dispatching an action

To dispatch an action using Rdux, use the `dispatch` method (aliased as `perform`).

Definition:

```ruby
def dispatch(action_name, payload, opts = {}, meta: nil)

alias perform dispatch
```

Arguments:
* `action_name`: The name of the service, class, or module that will process the action. This is persisted as an instance of `Rdux::Action` in the database, with its `name` attribute set to `action_name`. The `action_name` should correspond to the class or module that implements the `call` or `up` method, referred to as "action" or “action performer.”
* `payload` (Hash): The input data passed as the first argument to the `call` or `up` method of the action performer. This is sanitized and stored in the database before being processed. The keys in the `payload` are stringified during deserialization.
* `opts` (Hash): Optional parameters passed as the second argument to the `call` or `up` method, if defined. This is useful when you want to avoid redundant database queries (e.g., if you already have an ActiveRecord object available). There is a helper that facitilates this use case. The implementation is clear enough IMO `(opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }`. `:ars` means ActiveRecords. Note that `opts` is not stored in the database and `payload` should be fully sufficient to perform an **action**. `opts` provides an optimization.
* `meta` (Hash): Additional metadata stored in the database alongside the `action_name` and `payload`. The `stream` key is particularly useful for scoping actions during reversions. For example, you can construct a `stream` based on the owner of action.

Example:

```ruby
Rdux.perform(
  Task::Create, 
  { task: { name: 'Foo bar baz' } }, 
  { ars: { user: current_user } }, 
  meta: {
    stream: { user_id: current_user.id, context: 'foo' }, 
    bar: 'baz'
  }
)
```

### 📈 Flow diagram

![Flow Diagram](docs/flow.png)

### 💪 Action

An action in Rdux is a Plain Old Ruby Object (PORO) that implements a class or instance method `call` or `up`.  
This method must return an `Rdux::Result` `struct`.  
Optionally, an action can implement a class or instance method `down` to specify how to revert it.

#### Action Structure:

* `call` or `up` method: Accepts a required `payload` and an optional `opts` argument. This method processes the action and returns an `Rdux::Result`.
* `down` method: Accepts the deserialized `down_payload` which is one of arguments of the `Rdux::Result` `struct` returned by the `up` method on success and saved in DB. `down` method can optionally accept the 2nd argument (Hash) which `:nested` key contains nested `Rdux::Action`s


See [🚛 Dispatching an action](#-dispatching-an-action) section.  

Examples:

```ruby
# app/actions/task/create.rb

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
# app/actions/task/delete.rb

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

#### Suggested Directory Structure:

The location that is often used for entities like actions accross code bases is `app/services`.  
This directory is de facto the bag of random objects.  
I'd recomment to place actions inside `app/actions` for better organization and consistency.  
Actions are consistent in terms of structure, input and output data.  
They are good canditates to create a new layer in Rails apps.

Structure:
```
.
└── app/actions/
    ├── activity/
    │   ├── common/
    │   │   └── fetch.rb
    │   ├── create.rb
    │   ├── stop.rb
    │   └── switch.rb
    ├── task/
    │   ├── create.rb
    │   └── delete.rb
    └── misc/
        └── create_attachment.rb
```

The [dedicated page about actions](docs/ACTIONS.md) contains more arguments in favor of actions.

### ⛩️ Returned `struct` `Rdux::Result`

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
* `ok` (Boolean): Indicates whether the action was successful. If `true`, the `Rdux::Action` is persisted in the database.
* `down_payload` (Hash): Passed to the action’s `down` method during reversion (`down` method is called on `Rdux::Action`). It does not have to be defined if an action does not implement the `down` method. `down_payload` is saved in the DB.
* `val` (Hash): Contains any additional data to return besides down_payload.
* `up_result` (Hash): Stores data related to the action’s execution, such as created record IDs, DB changes, responses from 3rd parties, etc.
* `save` (Boolean): If `true` and `ok` is `false`, the action is saved as a `Rdux::FailedAction`.
* `after_save` (Proc): Called just before the `dispatch` method returns the `Rdux::Result` with `Rdux::Action` or `Rdux::FailedAction` as an argument.
* `nested` (Array of `Rdux::Result`): `Rdux::Action` can be connected with other `rdux_actions`. `Rdux::FailedAction` can be connected with other `rdux_actions` and `rdux_failed_actions`. To establish an association, a given action must `Rdux.dispatch` other actions in the `up` or `call` method and add the returned by the `dispatch` value (`Rdux::Result`) to the `:nested` array
* `action`: Rdux assigns `Rdux::Action` or `Rdux::FailedAction` to this argument

### ⏮️ Revert action

To revert an action it's required to call the `down` method on the persisted in DB instance of `Rdux::Action`.  
It must have the `down_payload` defined and the action (action performer) must have the `down` method implemented. 

![Revert action](docs/down.png)

The `down_at` attribute of `Rdux::Action` is set and persisted after the successful reversal.

It is not possible to revert a `Rdux::Action` if there are newer, not reversed `Rdux::Action`s in a given stream if a stream is defined or in general. See `meta` in [🚛 Dispatching an action](#-dispatching-an-action) section.

### 🗿 Data model

```ruby
payload = { 
  task: { 'name' => 'Foo bar baz' },
  user_id: 159163583
}

res = Rdux.dispatch(Task::Create, payload)

res.action
# #<Rdux::Action:0x000000011c4d8e98
#   id: 1,
#   name: "Task::Create",
#   up_payload: {"task"=>{"name"=>"Foo bar baz"}, "user_id"=>159163583},
#   down_payload: {"task_id"=>207620945},
#   down_at: nil,
#   up_payload_sanitized: false,
#   up_result: nil,
#   meta: {},
#   stream_hash: nil,
#   rdux_action_id: nil,
#   rdux_failed_action_id: nil,
#   created_at: Fri, 28 Jun 2024 21:35:36.838898000 UTC +00:00,
#   updated_at: Fri, 28 Jun 2024 21:35:36.839728000 UTC +00:00>>

res.action.down
```

### 😷 Sanitization

When `Rdux.perform` is called the `up_payload` gets sanitized using `Rails.application.config.filter_parameters` before it is saved in DB.  
The action's `up` or `call` method receives the unsanitized version.  
It's not possible to retry the `Rdux::Action` via calling the `#up` method if the `up_payload` got sanitized. 

### 🗣️ Queries

Most likely, it won't be needed to save `Rdux::Action` for every request a Rails app receives.  
The suggested approach is to save `Rdux::Action`s for CUD from CRUD and to not save for Reads.  
This approach organically creates a new layer - queries in addition to actions.  
Thus, it is required to call `Rdux.perform` only for actions.

It is suggested to create the `perform` method that calls out `Rdux.perform` or query depending on the presence of `action` or `query` keywords.  
This method can set `meta` attributes, fulfill params validation, etc.

Example:
```ruby
class TasksController < ApiController
  def show
    perform(
      query: Task::Show,
      payload: { id: params[:id] }
    )
  end

  def create
    perform(
      action: Task::Create,
      payload: create_task_params
    )
  end
end
```

### 🕵️ Indices

Both `Rdux::Action` and `Rdux::FailedAction` are standard ActiveRecord models.  
You can inherit from them and extend.  
Remember to create indices depending on your use cases. 
Especially is you use Postgres and make queries based on `JSONB` columns.

Example:
```ruby
class Action < Rdux::Action
  include Actionable
end
```

## 👩🏽‍🔬 Test

### 💉 Setup

```bash
$ cd test/dummy
$ DB=all bin/rails db:create
$ DB=all bin/rails db:prepare
$ cd ../..
```

### 🧪 Run tests

```bash
$ DB=postgres bin/rails test
$ DB=sqlite bin/rails test
```

## 📄 License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 👨‍🏭 Author

Zbigniew Humeniuk from [Art of Code](https://artofcode.co)

