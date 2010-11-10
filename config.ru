$:.unshift File.join(File.dirname(__FILE__), "lib")
require "streaker"

run Streaker::Web::Application
