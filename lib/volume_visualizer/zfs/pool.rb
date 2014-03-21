module VolumeVisualizer
  module ZFS
    class Pool
      attr_reader :pool_name

      def self.query_command(pool_name = "tank")
        attrs = ATTRS.collect { |a| a.to_s.gsub("_","") }.join(",")
        command = "zfs list -t all -H -r -o #{attrs} #{pool_name}"
        if ENV["USER"] != "root"
          command = "sudo " + command
        else
          command
        end
      end

      def initialize(pool_name)
        @pool_name = pool_name
      end

      def data
        STDERR.puts "reading ZFS data"
        File.popen(Pool.query_command pool_name).readlines
      end
    end
  end
end
