# Rdux - A Minimal Event Sourcing Plugin for Rails

<div align="center">

  <div>
    <img width="500px" src="docs/logo.webp">
  </div>

![GitHub](https://img.shields.io/github/license/artofcodelabs/rdux)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/artofcodelabs/rdux)

</div>

Rdux is a lightweight, minimalistic Rails plugin designed to introduce event sourcing and audit logging capabilities to your Rails application. With Rdux, you can efficiently track and store the history of actions performed within your app, offering transparency and traceability for key processes.

**Key Features**

* **Audit Logging** 👉 Rdux stores sanitized input data, the name of module or class (action performer) responsible for processing them, processing results, and additional metadata in the database.
* **Model Representation** 👉 Before action is executed it gets stored in the database through the `Rdux::Action` model. `Rdux::Action` is converted to the `Rdux::FailedAction` when it fails. These models can be nested, allowing for complex action structures.
* **Revert and Retry** 👉 `Rdux::Action` can be reverted. `Rdux::FailedAction` retains the input data and processing results necessary for implementing custom mechanisms to retry failed actions.
* **Metadata** 👉 Metadata can include the ID of the authenticated resource responsible for performing a given action, as well as resource IDs from external systems related to the action. This creates a clear audit trail of who executed each action and on whose behalf.
* **Streams** 👉 Rdux enables the identification of action chains (streams) by utilizing resource IDs stored in metadata. This makes it easy to query and track related actions.

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
def dispatch(action, payload, opts = {}, meta: nil)

alias perform dispatch
```

Arguments:

* `action`: The name of the module or class (action performer) that processes the action. This is stored in the database as an instance of `Rdux::Action`, with its `name` attribute set to `action` (e.g., `Task::Create`).
* `payload` (Hash): The input data passed as the first argument to the `call` or `up` method of the action performer. The data is sanitized and stored in the database before being processed by the action performer. During deserialization, the keys in the `payload` are converted to strings.
* `opts` (Hash): Optional parameters passed as the second argument to the `call` or `up` method, if defined. This can help avoid redundant database queries (e.g., if you already have an ActiveRecord object available before calling `Rdux.perform`). A helper is available to facilitate this use case: `(opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }`, where `:ars` represents ActiveRecord objects. Note that `opts` is not stored in the database, and the `payload` should be fully sufficient to perform an **action**. `opts` provides an optimization.
* `meta` (Hash): Additional metadata stored in the database alongside the `action` and `payload`. The `stream` key is particularly useful for specifying the stream of actions used during reversions. For example, a `stream` can be constructed based on the owner of the action.

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

### 🕵️‍♀️ Processing an action

Action in Rdux is processed by an action performer which is a Plain Old Ruby Object (PORO) that implements a class or instance method `call` or `up`.  
This method must return a `Rdux::Result` `struct`.  
Optionally, an action can implement a class or instance method `down` to specify how to revert it.

#### Action Structure:

* `call` or `up` method: Accepts a required `payload` and an optional `opts` argument. This method processes the action and returns a `Rdux::Result`.
* `down` method: Accepts the deserialized `down_payload` which is one of arguments of the `Rdux::Result` `struct` returned by the `up` method on success and saved in DB. `down` method can optionally accept the 2nd argument (Hash) which `:nested` key contains nested `Rdux::Action`s

See [🚛 Dispatching an action](#-dispatching-an-action) section.

Examples:

```ruby
# app/actions/task/create.rb

class Task
  class Create
    def up(payload, opts)
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
* `down_payload` (Hash): Passed to the action performer’s `down` method during reversion (`down` method is called on `Rdux::Action`). It does not have to be defined if an action performer does not implement the `down` method. `down_payload` is saved in the DB.
* `val` (Hash): Contains different returned data than `down_payload`.
* `up_result` (Hash): Stores data related to the action’s execution, such as created record IDs, DB changes, responses from 3rd parties, etc.
* `save` (Boolean): If `true` and `ok` is `false`, the action is saved as a `Rdux::FailedAction`.
* `after_save` (Proc): Called just before the `dispatch` method returns the `Rdux::Result` with `Rdux::Action` or `Rdux::FailedAction` as an argument.
* `nested` (Array of `Rdux::Result`): `Rdux::Action` can be connected with other `rdux_actions`. `Rdux::FailedAction` can be connected with other `rdux_actions` and `rdux_failed_actions`. To establish an association, a given action must `Rdux.dispatch` other actions in the `up` or `call` method and add the returned by the `dispatch` value (`Rdux::Result`) to the `:nested` array
* `action`: Rdux assigns `Rdux::Action` or `Rdux::FailedAction` to this argument

### ⏮️ Reverting an Action

To revert an action, call the `down` method on the persisted in DB `Rdux::Action` instance.  
The `Rdux::Action` must have a `down_payload` defined and the action (action performer) must have the `down` method implemented.

![Revert action](docs/down.png)

The `down_at` attribute is set upon successful reversion. Actions cannot be reverted if there are newer, unreverted actions in the same stream (if defined) or in general. See `meta` in [🚛 Dispatching an action](#-dispatching-an-action) section.

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

When calling `Rdux.perform`, the `up_payload` is sanitized using `Rails.application.config.filter_parameters` before saving to the database.  
The action’s `up` or `call` method receives the unsanitized version.  
Note that if the `up_payload` is sanitized, the `Rdux::Action` cannot be retried via calling the `#up` method.

### 🗣️ Queries

Most likely, it won't be needed to save a `Rdux::Action` for every request a Rails app receives.  
The suggested approach is to save `Rdux::Action`s for Create, Update, and Delete (CUD) operations.  
This approach organically creates a new layer - queries in addition to actions.  
Thus, it is required to call `Rdux.perform` only for actions.

An example approach is to create the `perform` method that calls `Rdux.perform` or a query depending on the presence of `action` or `query` keywords.  
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

### 🕵️ Indexing

 Depending on your use case, create indices, especially when using PostgreSQL and querying based on JSONB columns.  
Both `Rdux::Action` and `Rdux::FailedAction` are standard ActiveRecord models.  
You can inherit from them and extend.  
Depending on your use case, create indices, especially when using PostgreSQL and querying based on `JSONB` columns.  

Example:
```ruby
class Action < Rdux::Action
  include Actionable
end
```

## 👩🏽‍🔬 Testing

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
