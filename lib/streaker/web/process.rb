require "pathname"
require "yaml"

module Streaker
  module Web
    module Process
      module_function
        def tmp
          Pathname.new(File.join(File.dirname(__FILE__), "..", "..", "..", "tmp"))
        end
        
        def pid_path
          tmp.join "vlc.pid"
        end
        
        def pid
          File.open(pid_path, "r") { |f| f.gets } if File.exist?(pid_path)
        end
        
        def alive?
          if !(current_pid = pid).blank?
            if `ps -xcp #{current_pid}` =~ /^\s*(\d+)\s+\S+\s+\S+\s+(\S+)\s*$/
              return ($~[1] == current_pid && $~[2] =~ /^vlc$/i) ? true : false
            end
          end; false
        end
        
        def playing_path
          tmp.join "playing.yml"
        end
        
        def playing
          YAML.load_file(playing_path) if alive? && File.exist?(playing_path)
        rescue; end
        
        def playing!(path=nil)
          if path
            ::Process.kill(:TERM, pid.to_i) if alive?
            sleep 0.1
            options = {
              :file => path,
              :daemon => true,
              :pid => Streaker::Web::Process.pid_path,
              :width => 720 }
            system Streaker::Vlc.new(path, options).command
            File.open(playing_path, "w") { |f| YAML.dump(path, f) }
          else
            not_playing!
          end
        end
        
        def not_playing!
          File.delete(playing_path)
        end
    end
  end
end
