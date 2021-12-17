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
