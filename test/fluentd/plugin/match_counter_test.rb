# frozen_string_literal: true
require 'test_helper'

module Fluent
  class MatchCounterTest < MatchCounterTestHelper
    sub_test_case :configuration do
      test :empty_config do
        assert_raise(Fluent::ConfigError) do
          create_driver('')
        end
      end

      test :missing_required do
        assert_raise(Fluent::ConfigError) do
          # Missing a required param in one of multiple configurations
          create_driver(%[
          <match_counter>
            matcher foo
            event_key foo

            name foo
          </match_counter>
          <match_counter>
            event_key foo

            name foo
          </match_counter>
          ])
        end
      end

      test :multiple do
        d = create_driver(config)

        assert_equal 2, d.instance_variable_get(:@config).elements.size
        assert_equal 'bar', d.instance_variable_get(:@config).elements[1]["matcher"]
      end
    end

    sub_test_case :filter do
      test :simple_matches do
        c = config(%[
        <match_counter>
          matcher foo
          regexp false
          name "${tag}.foobar"
        </match_counter>
        ])
        e = [
          { foo: 'message foo bar' },
          { bar: 'message foo bar' }
        ]

        f = filter(e, c)

        expected = [[
          {name: "foo", type: "count", value: 1},
          {name: "test.foobar", value: 1}
        ],[
          {name: "bar", value: 1},
          {name: "test.foobar", value: 1}
        ]]

        assert_equal(expected, f)
      end

      test :with_fields do
        c = %[
        <match_counter>
          matcher with_fields
          regexp false
          event_key message
          name "with.fields"
          type counter
          fields {"attributes":{"host.name":"localhost"}}
        </match_counter>
        ]
        e = [
          { message: 'message with_fields to be merged' }
        ]

        f = filter(e, c)

        expected = [
          {
            name: "with.fields",
            value: 1,
            type: "counter",
            "attributes" => {
              "host.name" => "localhost"
            }
          }
        ]

        assert_equal(expected, f.first)
      end
    end
  end
end
