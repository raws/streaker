require "erb"
require "pathname"
require "rubygems"
require "sinatra/base"

module Streaker
  module Web
    class Application < Sinatra::Base
      def self.root
        Pathname.new File.join(File.dirname(__FILE__), "..", "..", "..")
      end
      
      set :root, root
      set :public, root.join("public")
      
      helpers do
        def search(query)
          options = { :in => ["/Volumes/Liberator/Media/Movies",
            "/Volumes/Liberator/Media/TV\\ Shows"] }
          Streaker::Search.new(query, options).results
        end
        
        def stream(file)
          Streaker::Web::Process.playing! file
        end
        
        def error(message=nil)
          @message = message
          erb :error
        end
      end
      
      get "/" do
        erb :index
      end
      
      get "/search" do
        @query = params[:q]
        return error "please specify a search query" if @query.blank?
        @results = search(@query)
        erb :search
      end
      
      post "/stream" do
        @file = params[:file]
        return error "please specify a file to stream" if @file.nil?
        return error "that file doesn't exist somehow" unless File.exist?(@file)
        stream(@file)
        redirect "/"
      end
    end
  end
end
