# frozen_string_literal: true
require 'bundler/setup'
require 'test/unit'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'test-unit'
require 'fluent/test'
require 'fluent/test/helpers'
require 'fluent/test/driver/filter'
require 'fluent/plugin/match_counter'

class Fluent::MatchCounterTestHelper < Test::Unit::TestCase
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

    d.filtered_records
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
end
