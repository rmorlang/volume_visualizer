# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'volume_visualizer/version'

Gem::Specification.new do |spec|
  spec.name          = "volume_visualizer"
  spec.version       = VolumeVisualizer::VERSION
  spec.authors       = ["Rick Lee-Morlang"]
  spec.email         = ["<rick@lee-morlang.com>"]
  spec.summary       = %q{Visualize data distribution in your storage volumes.}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/rleemorlang/volume_visualizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency "thor"
  spec.add_dependency "json"
end
