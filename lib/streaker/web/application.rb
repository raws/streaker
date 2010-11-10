require "erb"
require "rubygems"
require "sinatra/base"

module Streaker
  module Web
    class Application < Sinatra::Base
      set :root, File.join(File.dirname(__FILE__), "..", "..", "..")
      
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
        error "please specify a search query" unless @query = params[:q]
        @results = search(@query)
        erb :search
      end
      
      post "/stream" do
        @file = params[:file]
        erb :error if @file.nil? || !File.exist?(@file)
        stream(@file)
        redirect "/"
      end
    end
  end
end
