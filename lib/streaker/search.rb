require "shellwords"

module Streaker
  class Search
    attr_reader :options
    
    def initialize(query, options={})
      @query = query
      @options = { :in => ["/"] }.merge(options)
    end
    
    def results
      @results ||= options[:in].inject([]) do |results, where|
        results += `#{command(where.sub(%r{/$}, ""))}`.strip.split("\n")
      end
    end
    
    def command(where)
      "#{find} #{where} #{query} -not -type d -and #{types}"
    end
    
    def find
      @find ||= `which find`.strip
    end
    
    def query
      criteria = @query.split(/\s+/).map do |term|
        term = "*#{term}*"
        "-iname #{term.shellescape}"
      end
      '\( ' + criteria.join(" -a ") + ' \)'
    end
    
    def types
      criteria = %w(avi m4v mov mp4 mpg mkv).map do |type|
        type = "*.#{type}"
        "-iname #{type.shellescape}"
      end
      '\( ' + criteria.join(" -o ") + ' \)'
    end
  end
end
