module VolumeVisualizer
  module ZFS
    class Base
      attr_reader :filesystems, :root, :name

      def initialize(name, data)
        @name = name || "unknown volume"
        @filesystems = {}

        data.each do |line|
          line.chomp!
          fs = ZFS::Filesystem.new(line)
          next if fs.snapshot? && fs.zero?
          if filesystems.empty?
            @root = fs
          else
            parent = filesystems[ fs.parent_name ]
            fs.parent = parent
            parent.children << fs
          end
          filesystems[fs.name] = fs
        end
      end

      def walk(nodes = [ root ], &block)
        nodes.each do |node|
          yield node
          walk node.children, &block
        end
      end

      def to_h
        {
          :name => name,
          :type => :root,
          :children => [
            {
              :name => "free space",
              :size => root.available.bytes,
              :size_human => root.available,
              :type => "free"
            },
            root.to_h
          ]
        }
      end

      def to_json
        to_h.to_json(:max_nesting => 50)
      end
    end
  end
end

