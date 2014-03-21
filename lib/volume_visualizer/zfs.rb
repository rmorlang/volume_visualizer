module VolumeVisualizer
  module ZFS
    ATTRS = [ :name, :available, :used, :referenced, :used_by_snapshots, 
      :used_by_dataset, :used_by_children, :compress_ratio, :type ]
    NON_BYTE_ATTRS = [ :name, :compress_ratio, :type ]
  end
end

require 'volume_visualizer/zfs/base'
require 'volume_visualizer/zfs/pool'
require 'volume_visualizer/zfs/filesystem'

