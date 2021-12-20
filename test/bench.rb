require 'test_helper'
require 'benchmark/ips'

module Fluent
  class MatchCounterBenchmarkTest < MatchCounterTestHelper
    DURATION   = 20.freeze
    NUM_EVENTS = 100.freeze

    test :benchmark do
      puts "Benchmark w/ #{NUM_EVENTS} events per payload for #{DURATION} seconds"
      puts " - Reports payloads per second"

      # With 100% matches.
      @e1 = []
      (1..(NUM_EVENTS/2)).each do
        @e1 << { foo: 'message foo bar' } # matching event
        @e1 << { bar: 'message foo bar' } # matching event
      end

      # With 50% matches.
      @e2 = []
      (1..(NUM_EVENTS/2)).each do
        @e2 << { foo: 'message foo bar' } # matching event
        @e2 << { ack: 'message ack' }     # missing event
      end

      # No matches.
      @e3 = (1..NUM_EVENTS).collect do
        { ack: 'message ack' }
      end

      # One match (in the middle)
      @e4 = @e3.dup
      @e4[NUM_EVENTS/2] = { foo: 'message foo bar' }


      ::Benchmark.ips do |x|
        x.config(width: 12, time: DURATION, warmup: 2)
        x.report('all:')   { filter(@e1, config) }
        x.report('50/50:') { filter(@e2, config) }

        x.report('50/50 w/ tag:') {
          filter(@e2, config.gsub('count_key foo', 'count_key "${tag}.foo"'))
        }

        x.report('none:')  { filter(@e3, config) }
        x.report('one:')   { filter(@e4, config) }

        x.compare!
      end
    end
  end
end
