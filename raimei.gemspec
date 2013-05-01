# -*- coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raimei/version'

Gem::Specification.new do |spec|
  spec.name          = "raimei"
  spec.version       = Raimei::VERSION
  spec.authors       = ["ITO Nobuaki"]
  spec.email         = ["daydream.trippers@gmail.com"]
  spec.description   = %q{Tiny pagination library}
  spec.summary       = %q{Tiny pagination library}
  spec.homepage      = "https://github.com/dayflower/raimei"
  spec.license       = "MIT"

  spec.files         = [
    "raimei.gemspec",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "lib/raimei.rb",
    "lib/raimei/navigation.rb",
    "lib/raimei/pager.rb",
    "lib/raimei/sorter.rb",
    "lib/raimei/version.rb",
    "spec/spec_helper.rb",
    "spec/navigation_spec.rb",
    "spec/pager_spec.rb",
    "spec/sorter_spec.rb",
  ]

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
