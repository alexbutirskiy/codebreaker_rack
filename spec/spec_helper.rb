require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rspec'
require 'bundler/setup'
require './lib/codebreaker_game'
require './lib/codebreaker_helper'
require './lib/user'
