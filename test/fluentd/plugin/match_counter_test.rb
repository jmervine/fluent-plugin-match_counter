# frozen_string_literal: true

require 'test_helper'

class Fluent::MatchCounterTest < Test::Unit::TestCase
  def setup
    super

    Fluent::Test.setup
    @time = Fluent::Engine.now
    @tag  = 'test'
  end

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::MatchCounter).configure(conf)
  end

  def filter(messages, conf)
    d = create_driver(conf)

    d.run(default_tag: 'test', start: true, shutdown: false) do
      messages.each do |message|
        d.feed(@time, message)
      end
    end

    d.filtered_records.first
  end

  def config(s = '')
    %[
      <match_counter>
        matcher   "^message.+foo.+$"
        event_key foo
        count_key foo
      </match_counter>
      <match_counter>
        matcher   bar
        regexp    false
        event_key bar
        count_key bar
      </match_counter>
    ] + s
  end

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
          count_key foo
        </match_counter>
        <match_counter>
          event_key foo
          count_key foo
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
        matcher   foo
        regexp    false
        event_key bar
        count_key foobar
      </match_counter>
      ])
      e = [ { bar: 'message foo bar' } ]

      f = filter(e, c)

      expected = {
        bar: 1,
        foobar: 1
      }

      assert_equal(expected, f)
    end
  end
end
