# -*- coding: utf-8 -*-
# vi: ft=ruby

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require :default

require File.expand_path("../app.rb", __FILE__)

run Sinatra::Application
