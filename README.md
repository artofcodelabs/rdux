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
* **Model Representation** 👉 Before action is executed it gets stored in the database through the `Rdux::Action` model. This model can be nested, allowing for complex action structures.
* **Exception Handling and Recovery** 👉 Rdux automatically creates a `Rdux::Action` record when an exception occurs during action execution. It retains the `payload` and allows you to capture additional data using `opts[:action].result`, ensuring all necessary information is available for retrying the action.
* **Metadata** 👉 Metadata can include the ID of the authenticated resource responsible for performing a given action, as well as resource IDs from external systems related to the action. This creates a clear audit trail of who executed each action and on whose behalf.

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

⚠️ Note: Rdux requires Rails 7.1+. It uses `jsonb` columns on PostgreSQL and `json` on other adapters.

## 🎮 Usage

### 🚛 Dispatching an action

To dispatch an action using Rdux, use the `dispatch` method (aliased as `perform`).

Definition:

```ruby
def dispatch(action, payload, opts: {}, meta: nil)

alias perform dispatch
```

Arguments:

* `action`: The name of the module or class (action performer) that processes the action. `action` is stored in the database as the `name` attribute of the `Rdux::Action` instance (e.g., `Task::Create`).
* `payload` (Hash): The input data passed as the first argument to the `call` method of the action performer. The data is sanitized and stored in the database before being processed by the action performer. During deserialization, the keys in the `payload` are converted to strings.
* `opts` (Hash): Optional parameters passed as the second argument to the `call` method, if defined. This can help avoid redundant database queries (e.g., if you already have an ActiveRecord object available before calling `Rdux.perform`). A helper is available to facilitate this use case: `(opts[:ars] || {}).each { |k, v| payload["#{k}_id"] = v.id }`, where `:ars` represents ActiveRecord objects. Note that `opts` is not stored in the database, and the `payload` should be fully sufficient to perform an **action**. `opts` provides an optimization.
* `meta` (Hash): Additional metadata stored in the database alongside the `action` and `payload`.

Example:

```ruby
Rdux.perform(
  Task::Create,
  { task: { name: 'Foo bar baz' } },
  opts: { ars: { user: current_user } },
  meta: { bar: 'baz' }
)
```

### 📈 Flow diagram

![Flow Diagram](docs/flow.png)

### 🕵️‍♀️ Processing an action

Action in Rdux is processed by an action performer which is a Plain Old Ruby Object (PORO) that implements the `self.call` method.
This method accepts a required `payload` and an optional `opts` argument.
`opts[:action]` stores the Active Record object.
`call` method processes the action and must return a `Rdux::Result` struct.

See [🚛 Dispatching an action](#-dispatching-an-action) section.

Example:

```ruby
# app/actions/task/create.rb

class Task
  module Create
    def self.call(payload, opts)
      user = opts.dig(:ars, :user) || User.find(payload['user_id'])
      task = user.tasks.new(payload['task'])
      if task.save
        Rdux::Result[ok: true, val: { task: }]
      else
        Rdux::Result[false, { errors: task.errors }]
      end
    end
  end
end
```

#### Suggested Directory Structure

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
  Result = Struct.new(:ok, :val, :result, :save, :nested, :action) do
    def save_failed?
      ok == false && save ? true : false
    end
  end
end
```

Arguments:

* `ok` (Boolean): Indicates whether the action was successful. If `true`, the `Rdux::Action` is persisted in the database.
* `val` (Hash): returned data.
* `result` (Hash): Stores data related to the action’s execution, such as created record IDs, DB changes, responses from 3rd parties, etc. that will be persisted as `Rdux::Action#result`.
* `save` (Boolean): If `true` and `ok` is `false`, the action is still persisted in the database.
* `nested` (Array of `Rdux::Result`): `Rdux::Action` can be connected with other `rdux_actions`. To establish an association, a given action must `Rdux.dispatch` other actions in the `call` method and add the returned by the `dispatch` value (`Rdux::Result`) to the `:nested` array
* `action`: Rdux assigns persisted `Rdux::Action` to this argument

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
#   payload: {"task"=>{"name"=>"Foo bar baz"}, "user_id"=>159163583},
#   payload_sanitized: false,
#   result: nil,
#   meta: {},
#   rdux_action_id: nil,
#   created_at: Fri, 28 Jun 2024 21:35:36.838898000 UTC +00:00,
#   updated_at: Fri, 28 Jun 2024 21:35:36.839728000 UTC +00:00>>
```

### 😷 Sanitization

When `Rdux.perform` is called, the `payload` is sanitized using `Rails.application.config.filter_parameters` before being saved to the database.
The action performer’s `call` method receives the unsanitized version.

### 🗣️ Queries

Most likely, it won't be necessary to save a `Rdux::Action` for every request a Rails app receives.
The suggested approach is to save `Rdux::Action`s for Create, Update, and Delete (CUD) operations.
This approach organically creates a new layer - queries in addition to actions.
Thus, it is required to call `Rdux.perform` only for actions.

One approach is to create a `perform` method that invokes either `Rdux.perform` or a query, depending on the presence of `action` or `query` keywords.
This method can also handle setting `meta` attributes, performing parameter validation, and more.

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

Depending on your use case, it’s recommended to create indices, especially when using PostgreSQL and querying JSONB columns.\
`Rdux::Action` is a standard ActiveRecord model.
You can inherit from it and extend.

Example:

```ruby
class Action < Rdux::Action
  include Actionable
end
```

### 🚑 Recovering from Exceptions

Rdux captures exceptions raised during the execution of an action and sets the `Rdux::Action#ok` attribute to `false`.
The `payload` is retained, but having only the input data is often not enough to retry an action.
It is crucial to capture data obtained during the action’s execution, up until the exception occurred.
This can be done by using `opts[:action].result` attribute to store all necessary data incrementally.

Example:

```ruby
class CreditCard
  class Charge
    class << self
      def call(payload, opts)
        create_res = create(payload.slice('user_id', 'credit_card'), opts.slice(:user))
        return create_res unless create_res.ok

        opts[:action].result = { credit_card_create_action_id: create_res.action.id }
        charge_id = PaymentGateway.charge(create_res.val[:credit_card].token, payload['amount'])[:id]
        if charge_id.nil?
          Rdux::Result[ok: false, val: { errors: { base: 'Invalid credit card' } }, save: true,
                       nested: [create_res]]
        else
          Rdux::Result[ok: true, val: { charge_id: }, nested: [create_res]]
        end
      end

      private

      def create(payload, opts)
        res = Rdux.perform(Create, payload, opts:)
        res.ok ? res : Rdux::Result[ok: false, val: { errors: res.val[:errors] }, save: true]
      end
    end
  end
end
```

## 🧩 Process

**Process** 👉 a series of actions or steps taken in order to achieve a particular end.

`Rdux::Process` is a persisted model that groups multiple `Rdux::Action`s.
It also stores an ordered list of `steps` (`jsonb`/`json`).

When a process starts:

* Steps run **sequentially** in the order defined in `STEPS`
* Process execution continues only when the latest process action returns `ok: true`
* Execution stops on the first failed action step (`ok == false`)
* `process.ok` is persisted from the latest non-`nil` step result

Key points:

* `Rdux::Process` **has many** `Rdux::Action`s (`process.actions`)
* `Rdux::Action` **belongs to** a process (`action.process`)
* `Rdux.start(ProcessModuleOrClass, payload)` starts a process performer (a PORO namespace/class with a `STEPS` constant)
* `STEPS` must be an `Array` (validated on `Rdux::Process`)
* `steps` is stored as `jsonb` on PostgreSQL and `json` on other adapters (default: `[]`)
* `STEPS` supports:
  * a step definition hash (`{ name: User::Create, payload: ->(payload, prev_res) { ... } }`)
  * a callable step (`->(payload, process) { ... }`)
* For hash steps, Rdux dispatches `Rdux.perform(step_name, step_payload, process: process)` (`step_payload` is the full process payload unless `payload:` proc is provided)
* For callable steps, Rdux calls the step with `(safe_payload, process)` and the step is responsible for dispatching an action (with `Rdux.perform(..., process:)`)
  * ⚠️ If a step returns `ok: false`, that step action is persisted (and can be assigned to the process) **only** when it also returns `save: true`. This is required.
* Inside an action performer, use `opts[:action]` to access the current persisted action, then traverse `opts[:action].process.actions` (and their `result`)
* Actions dispatched *inside* an action performer (via `Rdux.perform`) are linked via `rdux_action_id` (`action.rdux_actions`) and are not automatically assigned to the process

Example:

```ruby
module Processes
  module Subscription
    module Create
      STEPS = [
        lambda { |payload, process|
          payload = payload.slice('plan_id', 'user', 'total_cents')
          Rdux.perform(::Subscription::Preview, payload, process:)
        },
        lambda { |payload, process|
          payload = payload.slice('user')
          Rdux.perform(User::Create, payload, process:)
        },
        { name: CreditCard::Create,
          payload: lambda { |payload, prev_res|
            payload.slice('credit_card').merge(user_id: prev_res.action.result['user_id'])
          } },
        { name: Payment::Create,
          payload: ->(_, prev_res) { { token: prev_res.val[:credit_card].token } } },
        { name: ::Subscription::Create,
          payload: ->(payload, prev_res) { payload.slice('plan_id').merge(ext_charge_id: prev_res.val[:charge_id]) } }
      ].freeze
    end
  end
end

res = Rdux.start(Processes::Subscription::Create, payload)
process = res.val[:process]

# from any action performer:
def self.call(payload, opts)
  results = opts[:action].process.actions.order(:id).pluck(:result)
  # ...
end
```

## 🛠️ Helpers

### `ActionResult`

`ActionResult` is not part of Rdux itself, but a useful helper you can copy into your app to persist DB changes and resource relations alongside an action.

It sets `action.result` with:

* `relations` — a map of `"model_name#id" => id` (or raw hashes) for each resource that was modified or created
* `db_changes` — `saved_changes` for each resource that was modified or created
* any extra key/value pairs passed as keyword arguments

It also creates an `ActionResource` record for each AR resource, linking it to the action via a polymorphic association.

**Usage:**

```ruby
# inside an action performer
opts[:action].result = ActionResult.call(
  action: opts[:action],
  resources: [task]
)

# action.result stored in DB:
# {
#   "relations"  => { "task#1" => 1 },
#   "db_changes" => {
#     "task#1" => {
#       "id"         => [nil, 1],
#       "name"       => [nil, "Foo bar baz"],
#       "user_id"    => [nil, 42],
#       "created_at" => [nil, "2024-06-28 21:35:36"],
#       "updated_at" => [nil, "2024-06-28 21:35:36"]
#     }
#   }
# }
```

Resources can be ActiveRecord objects or plain hashes (merged directly into `relations`):

```ruby
ActionResult.call(
  action: opts[:action],
  resources: [task, { user_id: user.id }],
  additional_info: 'Foo Bar Baz'
)
```

**`ActionResource` model** (`app/models/action_resource.rb`):

```ruby
class ActionResource < ApplicationRecord
  belongs_to :action, class_name: 'Rdux::Action'
  belongs_to :resource, polymorphic: true

  validates :action_id, uniqueness: { scope: %i[resource_type resource_id] }
  validates :resource_type, presence: true
end
```

**`ActionResult` service** (`app/services/action_result.rb`):

```ruby
class ActionResult
  class << self
    def call(action:, resources:, **custom)
      result = { relations: {}, db_changes: {} }

      resources.each do |resource|
        if resource.is_a?(Hash)
          result[:relations].merge!(resource)
          next
        end

        key = relation_key(resource)
        result[:relations][key] = resource.id
        result[:db_changes][key] = resource.saved_changes if resource.saved_changes.present?
      end

      persist_relations(result[:relations], action.id)
      result.merge(custom)
    end

    private

    def relation_key(resource)
      "#{resource.class.name.underscore}##{resource.id}"
    end

    def resource_type_for(name)
      type = name.sub(/_id$/, '').sub(/#\d+$/, '').camelize
      resource_class = type.safe_constantize
      resource_class && resource_class < ApplicationRecord ? type : nil
    end

    def persist_relations(relations, action_id)
      relations.each do |name, id|
        resource_type = resource_type_for(name)
        next if resource_type.nil? || !id.to_s.match?(/\A\d+\z/)

        ActionResource.create!(action_id:, resource_type:, resource_id: id)
      end
    end
  end
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
