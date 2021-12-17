# coding: utf-8
# frozen_string_literal: true
require 'fluent/plugin/filter'

module Fluent
  class MatchCounter < Plugin::Filter
    Fluent::Plugin.register_filter('match_counter', self)

    config_section :match_counter, required: true, multi: true do
      # REQUIRED
      desc 'Pattern to be matched'
      config_param :matcher, :string

      desc 'Input key, where match event is contained'
      config_param :event_key, :string

      desc 'Count key, for counter output'
      config_param :count_key, :string

      # OPTIONAL
      desc 'Use RegExp to match value'
      config_param :regexp, :bool, default: true

      desc 'Number events matched to emit count'
      config_param :count, :integer, default: 1
    end

    def configure(conf)
      super
    end

    def filter(tag, time, record)
      out = {}
      @match_counter.each do |mc|
        ek = mc[:event_key].to_sym
        next unless record.has_key?(ek)

        str = record[ek]
        if !!((mc[:regexp] && Regexp.new(mc[:matcher]).match(str)) || \
          str.include?(mc[:matcher]))
          out.merge!(mc[:count_key].to_sym => 1)
        end
      end

      return nil if out.empty?
      out
    end
  end
end
