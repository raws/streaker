require "rbconfig"

module Streaker
  # A helpful module for determining the current operating system. Stolen from
  # http://rbjl.net/35-how-to-properly-check-for-your-ruby-interpreter-version-and-os.
  module OS
    class << self
      def is?(os)
        os === RbConfig::CONFIG["host_os"]
      end
      alias :is :is?

      def to_s
        RbConfig::CONFIG["host_os"]
      end
    end

    module_function
      def nix?
        OS.is? /bsd|linux|cygwin/
      end

      def mac?
        OS.is? /mac|darwin/
      end

      def windows?
        OS.is? /mswin|mingw/
      end
      
      def posix?
        nix? || mac? || Process.respond_to?(:fork)
      end
  end
end
