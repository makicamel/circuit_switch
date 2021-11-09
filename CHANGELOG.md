## 0.4.1

* Fix bug `if` `stop_report_if_reach_limit` options don't receive `false`.
* Fix to report error with stacktrace.
* Fix not to update run count when run isn't executable.

## 0.4.0

### Breaking Changes

* Be able to choice to notify `CircuitSwitch::CalledNotification` or `String`.  
Improve `config/initializers/circuit_switch.rb` like following.

```diff
CircuitSwitch.configure do |config|
-  config.reporter = ->(message) { Bugsnag.notify(message) }
+  config.reporter = ->(message, error) { Bugsnag.notify(error) }
```

## 0.3.0

### Breaking Changes

* Modify `key` to unique by default.
To migrate, run next.

```
rails generate circuit_switch:migration circuit_switch make_key_unique
rails db:migrate
```

### Changes

* Fix to save switch when block for `CircuitSwitch.run` raises error.

## 0.2.2

### New features

* Add `key_column_name` to configuration for aliasing `circuit_switches.key`.

### Changes

* Declare dependent on ActiveSupport instead of implicitly dependent.

## 0.2.1

### New features

* Add `initially_closed` option to `run` and `open?`.
* Add `key` argument for easy handling for human more than caller.  
To migrate, run next.

```
rails generate circuit_switch:migration circuit_switch add_key
rails db:migrate
```

### Changes

* Modify log level from warn to info when default value for `close_if_reach_limit` is used.
* Suppress warning that ivar is not initialized.

## 0.2.0

### Breaking Changes

* Modify default value of `CircuitSwitch.run` argument `close_if_reach_limit` from true to false.

## 0.1.2

* Modify `CircuitSwitch.open?` receives same arguments as `CircuitSwitch.run`

## 0.1.1

* Fix bug due_date is not set.
