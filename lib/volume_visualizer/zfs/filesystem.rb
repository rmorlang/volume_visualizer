module VolumeVisualizer
  module ZFS
    class Filesystem
      attr_accessor *ATTRS
      attr_accessor :children, :parent

      def initialize(string)
        @children = []

        params = string.split("\t")
        ATTRS.each do |attr|
          val = params.shift
          unless NON_BYTE_ATTRS.include? attr
            val = DataSizeString.new(val)
          end
          instance_variable_set "@#{attr.to_s}", val
        end
      end

      def depth
        depth = name.split("/").size
        depth -= 1 unless snapshot?
        depth
      end

      def parent_name
        if snapshot?
          name.split("@").first
        else
          File.dirname(name)
        end
      end

      def snapshot?
        type == "snapshot"
      end

      def zero?
        used.bytes == 0
      end

      def dump
        ATTRS.each do |attr|
          puts "%18s %s" % [attr, self.send(attr)]
        end
      end

      def to_h
        hash = {
          :name => name,
          :type => type,
          :size => used.bytes,
          :size_human => used,
          :type => type,
        }
        unless children.empty?
          hash[:children] = [
            {
            :name => name + " (data)",
            :type => "filesystem",
            :size => referenced.bytes,
            :size_human => referenced
          }
          ]
          hash[:type] = "container"
          children.each do |child|
            hash[:children] << child.to_h
          end
        end

        hash
      end
    end
  end
end
