# fluent-plugin-match_counter

[![Gem Version](https://badge.fury.io/rb/fluentd-plugin-match_counter.svg)](https://badge.fury.io/rb/fluentd-plugin-match_counter)
[![Github Actions: master](https://github.com/jmervine/fluent-plugin-match_counter/actions/workflows/ruby.yml/badge.svg??branch=master)](https://github.com/jmervine/fluent-plugin-match_counter/actions/workflows/ruby.yml)

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

## Configuration

Each of the following params should be contained within one or many
`match_counter` sections. For each section, the plugin will attempt to match
and emit a counter per the configurations in that section. See example
configuration below.


| param       | type   | required? | default | desc                                                                                                                                |
| ---         | ---    | ---       | ---     | ---                                                                                                                                 |
| `matcher`   | string | yes       | n/a     | The string or regex to be matched                                                                                                   |
| `event_key` | string | no        | `nil`   | If defined, the field within the top level event to match against. If `nil`, then the entire event will be stringified and checked. |
| `name`      | string | yes       | n/a     | The counter name to be included as part of the output                                                                               |
| `regexp`    | bool   | no        | `true`  | Use RegExp matching, if false, the an simple string match will be used                                                              |
| `type`      | string | no        | `nil`   | If present, include a type field in the output with the set value                                                                   |
| `fields`    | hash   | no        | `nil`   | Hash of fields to merged in the output hash                                                                                         |

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
            name "${tag}.foo.counter"
            type count
        </match_counter>
        <match_counter>
            matcher bar
            event_key message
            name "${tag}.bar.counter"
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
[ "some_tag", 1640022113, { message: 'message foo' }]
```

With configuration:
```
<match_counter>
  matcher "^.+ foo$"
  event_key message
  name "${tag}.foo.count"
  type count
  fields {"attributes":{"host.name":"localhost"}}
</match_counter>
```

Output:
```
{
    name: "some_tag.foo.count",
    type: "count",
    value: 1,
    "attributes" => {
        "host.name":"localhost"
    }
}
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
                all:    55.000  i/100ms
              50/50:    57.000  i/100ms
       50/50 w/ tag:    54.000  i/100ms
               none:    65.000  i/100ms
                one:    74.000  i/100ms
Calculating -------------------------------------
                all:    534.709  (± 5.6%) i/s -     10.670k in  20.023768s
              50/50:    558.507  (± 5.7%) i/s -     11.172k in  20.074369s
       50/50 w/ tag:    556.929  (± 5.4%) i/s -     11.124k in  20.036188s
               none:    721.776  (± 5.5%) i/s -     14.430k in  20.058260s
                one:    718.533  (± 5.6%) i/s -     14.356k in  20.050440s

Comparison:
               none::      721.8 i/s
                one::      718.5 i/s - same-ish: difference falls within error
              50/50::      558.5 i/s - 1.29x  (± 0.00) slower
       50/50 w/ tag::      556.9 i/s - 1.30x  (± 0.00) slower
                all::      534.7 i/s - 1.35x  (± 0.00) slower

.
Finished in 110.13594 seconds.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jmervine/fluentd-plugin-match_counter.
