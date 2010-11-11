require "shellwords"
require "rubygems"
require "json"

module Streaker
  class Exif
    attr_reader :file
    
    def initialize(file, *attributes)
      @file = file
      @requested = attributes.map { |a| "-#{a}" }
    end
    
    def [](key)
      attributes[key]
    end
    
    def attributes
      @attributes ||= JSON.parse(`#{command}`).first
    end
    
    def command
      command = "#{exiftool} -json"
      command << " #{@requested.join(" ")}" unless @requested.empty?
      command << " #{file.shellescape}"
    end
    
    def exiftool
      self.class.exiftool || `which exiftool`.strip
    end
    
    class << self
      attr_accessor :exiftool
    end
  end
end
