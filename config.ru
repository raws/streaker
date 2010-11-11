$:.unshift File.join(File.dirname(__FILE__), "lib")
require "streaker"
load "config.rb" if File.exist?("config.rb")

run Streaker::Web::Application
