module Streaker
  class Vlc
    attr_reader :file, :options
    
    def initialize(file, options={})
      @file = file
      @options = options
    end
    
    def command
      command = vlc
      command << " -I #{options[:interface] || "dummy"}"
      if options[:interface] == "rc" && socket = options[:socket]
        command << " --rc-#{socket =~ /:\d+$/ ? "host" : "unix"}=#{socket}"
      end
      command << " --daemon" if options[:daemon] || options[:interface] == "dummy"
      command << " --pidfile #{options[:pid]}" if options[:pid] && options[:daemon]
      command << " #{file.shellescape} vlc://quit"
      command << " --sout='##{transcode_module}:#{standard_module}'"
    end
    
    def vlc
      @vlc ||= if options[:vlc]
        options[:vlc]
      elsif OS.posix? && !(vlc = `which vlc`).blank?
        vlc.strip
      elsif OS.mac?
        "/Applications/VLC.app/Contents/MacOS/VLC"
      end
    end
    
    def module_for(name, options={})
      options = options.inject([]) do |opts, (key, val)|
        opts << "#{key}=#{val}"
      end
      "#{name}{#{options.join(",")}}"
    end
    
    def transcode_module
      options = { :vcodec => "h264", :venc => "x264", :vb => @options[:vbr] || 512,
        :fps => 24, :acodec => "mpga", :ab => @options[:abr] || 96, :channels => 2 }
      if max_width = @options[:width]
        exif = Exif.new(file, "ImageWidth", "ImageHeight")
        options[:width] = max_width
        options[:height] = (exif["ImageHeight"] * (max_width.to_f / exif["ImageWidth"])).to_i
      elsif scale = @options[:scale]
        options[:scale] = scale
      end
      module_for :transcode, options
    end
    
    def standard_module
      options = { :access => "http", :mux => "ts",
        :dst => @options[:bind] || "0.0.0.0:3555" }
      module_for :standard, options
    end
  end
end
