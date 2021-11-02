# circuit_switch

circuit_switch is a gem for 'difficult' application; for example, few tests, too many meta-programming codes, low aggregation classes and few deploys.  
This switch helps make changes easier and deploy safely.  
You can deploy and check with a short code like following if the change is good or not, and when a problem is found, you can undo it without releasing it.

```ruby
if CircuitSwitch.report.open?
  # new codes
else
  # old codes
end
```

You can also specify conditions to release testing features.

```ruby
CircuitSwitch.run(if: -> { current_user.testing_new_feature? }) do
  # testing feature codes
end
```

CircuitSwitch depends on ActiveRecord and ActiveJob.

## Installation

Add this line to your application's Gemfile and run `bundle install`:

```ruby
gem 'circuit_switch'
```

Run generator to create initializer and modify `config/initizlizers/circuit_switch.rb`:

```
rails generate circuit_switch:install
```

Generate a migration for ActiveRecord.  
This table saves named key, circuit caller, called count, limit count and so on.

```
rails generate circuit_switch:migration circuit_switch
rails db:migrate
```

## Usage

### `run`

When you want to deploy and undo it if something unexpected happens, use `CircuitSwitch.run`.

```ruby
CircuitSwitch.run do
  # experimental codes
end
```

`run` basically calls the received proc. But when a condition is met, it closes the circuit and does not evaluate the proc.  
To switch circuit opening and closing, a set of options can be set. Without options, the circuit is always open.  
You can set `close_if_reach_limit: true` so that the circuit is only open for 10 invocations. The constant 10 comes from the table definition we have arbitrarily chosen. In case you need a larger number, specify it in the `limit_count` option in combination with `close_if_reach_limit: true`, or alter default constraint on `circuit_switches.run_limit_count`.

- `key`: [String] The identifier to find record by. If `key` has not been passed, `circuit_switches.caller` is chosen as an alternative.
- `if`: [Boolean, Proc] Calls proc when the value of `if` is evaluated truthy (default: true)
- `close_if`: [Boolean, Proc] Calls proc when the value of `close_if` is evaluated falsy (default: false)
- `close_if_reach_limit`: [Boolean] Stops calling proc when `circuit_switches.run_count` has reached `circuit_switches.run_limit_count` (default: false)
- `limit_count`: [Integer] Mutates `circuit_switches.run_limit_count` whose value defined in schema is 10 by default. (default: nil)  
  Can't be set to 0 when `close_if_reach_limit` is true. This option is only relevant when `close_if_reach_limit` is set to true.
- `initially_closed`: [Boolean] Creates switch with terminated mode (default: false)

To close the circuit at a specific date, code goes like:

```ruby
CircuitSwitch.run(close_if: -> { Date.today >= some_day }) do
  # testing codes
end
```

Or when the code of concern has been called 1000 times:

```ruby
CircuitSwitch.run(close_if_reach_limit: true, limit_count: 1_000) do
  # testing codes
end
```

To run other codes when circuit closes, `run?` is available.

```ruby
circuit_open = CircuitSwitch.run { ... }.run?
unless circuit_open
  # other codes
end
```

`CircuitSwitch.run.run?` has syntax sugar. `open?` doesn't receive proc.

```ruby
if CircuitSwitch.open?
  # new codes
else
  # old codes
end
```

### `report`

When you just want to report, set your `reporter` to initializer and then call `CircuitSwitch.report`.

```ruby
CircuitSwitch.report(if: some_condition)
```

`report` just reports the line of code is called. It doesn't receive proc. It's useful for refactoring or removing dead codes.  
Same as `run`, some conditions can be set. By default, reporting is stopped when reached the specified count. The default count is 10. To change this default value, modify `circuit_switches.report_limit_count` default value in the migration file.  
`report` receives optional arguments.

- `key`: [String] Named key to find switch instead of caller  
  If no key passed, use caller.
- `if`: [Boolean, Proc] Report when `if` is truthy (default: true)
- `stop_report_if`: [Boolean, Proc] Report when `close_if` is falsy (default: false)
- `stop_report_if_reach_limit`: [Boolean] Stop reporting when reported count reaches limit (default: true)
- `limit_count`: [Integer] Limit count. Use `report_limit_count` default value if it's nil (default: nil)  
  Can't be set 0 when `stop_report_if_reach_limit` is true

To know about report is executed or not, you can get through `report?`.  
Of course you can chain `report` and `run` or `open?`.

#### `with_backtrace`

Reporter reports a short message by default like `Watching process is called for 5th. Report until for 10th.`.  
When your reporting tool knows about it's caller and backtrace, this is enough (e.g. Bugsnag).  
When your reporting tool just reports plain message (e.g. Slack), you can set `with_backtrace` true to initializer. Then report has a long message with backtrace like:

```
Watching process is called for 5th. Report until for 10th.
called_path: /app/services/greetings_service:21 block in validate
/app/services/greetings_service:20 validate
/app/services/greetings_service:5 call
/app/controllers/greetings_controller.rb:93 create
```

## Test

To test, FactoryBot will look like this;

```ruby
FactoryBot.define do
  factory :circuit_switch, class: 'CircuitSwitch::CircuitSwitch' do
    sequence(:key) { |n| "/path/to/file:#{n}" }
    sequence(:caller) { |n| "/path/to/file:#{n}" }
    due_date { Date.tomorrow }

    trait :initially_closed do
      run_is_terminated { true }
    end
  end
end
```

## Task

When find a problem and you want to terminate running or reporting right now, execute a task with it's caller.  
You can specify either key or caller.

```
rake circuit_switch:terminate_to_run[your_key]
rake circuit_switch:terminate_to_report[/app/services/greetings_service:21 block in validate]
```

In case of not Rails applications, add following to your Rakefile:

```ruby
require 'circuit_switch/tasks'
```

## Reminder for cleaning up codes

Too many circuits make codes messed up. We want to remove circuits after several days, but already have too many TODO things enough to remember them.  
Let's forget it! Set `due_date_notifier` to initializer and then call `CircuitSwitch::DueDateNotifier` job daily. It will notify the list of currently registered switches.  
By default, due_date is 10 days after today. To modify, set `due_date` to initializer.

## GUI to manage switches

Under development :)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/makicamel/circuit_switch. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/makicamel/circuit_switch/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CircuitSwitch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/makicamel/circuit_switch/blob/master/CODE_OF_CONDUCT.md).
