# fluent-plugin-match_counter

A simple FluentD Filter plugin to match events and create a counter for them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluentd-plugin-match_counter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fluentd-plugin-match_counter

### Example Configuration

```
<source>
  @type tail
  path dummy.log
  tag dummy
  format json
</source>

<match dummy>
    @type copy
    <store>
        @type http
        endpoint http://localhost:3000/logs
        open_timeout 2
        json_array true
    </store>
    <store>
        @type relabel
        @label @COUNTER
    </store>
</match>

# Handle counter event stream.
<label @COUNTER>
    <filter>
        @type match_counter

        <match_counter>
            matcher foo
            event_key message
            count_key "${tag}.foo.counter"
        </match_counter>
        <match_counter>
            matcher bar
            event_key message
            count_key "${tag}.bar.counter"
        </match_counter>
    </filter>
    <match>
        @type http
        endpoint http://localhost:3000/metrics
        open_timeout 2
        json_array true
    </match>
</label>
```

### Output Example

With record:
```
{ foo: 'message foo' }
```

With configuration:
```
<match_counter>
  matcher foo
  event_key foo
  count_key "foo.count"
</match_counter>
```

Outputs:
```
{ :"foo.count" => 1 }
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then,
run `bundle exec rake` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

### Benchmarks

#### Run w/
```
bundle exec rake bench
```

#### Last Run
```
Benchmark w/ 100 events per payload for 20 seconds
 - Reports payloads per second
Warming up --------------------------------------
                all:    57.000  i/100ms
              50/50:    60.000  i/100ms
       50/50 w/ tag:    54.000  i/100ms
               none:    77.000  i/100ms
                one:    74.000  i/100ms
Calculating -------------------------------------
                all:    558.298  (± 5.2%) i/s -     11.172k in  20.069121s
              50/50:    578.784  (± 5.0%) i/s -     11.580k in  20.060673s
       50/50 w/ tag:    530.287  (± 5.1%) i/s -     10.584k in  20.014558s
               none:    763.879  (± 4.5%) i/s -     15.246k in  20.000892s
                one:    750.439  (± 5.2%) i/s -     15.022k in  20.076956s
.
Finished in 110.255193 seconds.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jmervine/fluentd-plugin-match_counter.
