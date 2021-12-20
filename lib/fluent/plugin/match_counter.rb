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

      desc 'Name for counter output, "${tag}" will be replaced with record tag'
      config_param :name, :string

      # OPTIONAL
      desc 'Input key, where match event is contained; if unset, then search entire event'
      config_param :event_key, :string, default: nil

      desc 'Use RegExp to match value'
      config_param :regexp, :bool, default: true

      desc 'Metric type passed to output'
      config_param :type, :string, default: nil

      desc 'Fields to be merged'
      config_param :fields, :hash, default: nil
    end

    def configure(conf)
      super
    end

    def filter(tag, time, record)
      out = []
      @match_counter.each do |mc|
        str = \
          begin
            ek = mc[:event_key].to_sym
            next unless ek.nil? || record.has_key?(ek)

            record[ek]
          rescue
            record.to_s
          end

        if !!((mc[:regexp] && Regexp.new(mc[:matcher]).match(str)) || \
          str.include?(mc[:matcher]))

          name = mc[:name].clone
          name.gsub!('${tag}', tag) if name.include?('${tag}')

          met = {
            name: name,
            value: 1
          }
          met[:type] = mc[:type] unless mc[:type].nil?
          met.merge!(mc[:fields]) unless mc[:fields].nil?

          out << met
        end
      end

      return nil if out.empty?
      out
    end

    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
      es.each do |time, record|
        begin
          new_es.add(time, filter(tag, time, record))
        rescue => e
          router.emit_error_event(tag, time, record, e)
        end
      end

      new_es
    end
  end
end
