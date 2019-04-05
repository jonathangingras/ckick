# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ckick/version'

Gem::Specification.new do |spec|
  spec.name          = "ckick"
  spec.version       = CKick::VERSION
  spec.authors       = ["Jonathan Gingras"]
  spec.email         = ["jonathan.gingras.1@gmail.com"]
  spec.license       = "MPL-2.0"

  spec.summary       = %q{Kick start a C/C++ CMake project structure from a single JSON file}
  spec.description   = %q{CKick is a simple gem that helps to kick start a C/C++ project using CMake with an arbitrary structure. Using a CKickfile (a simple JSON), ckick is able to generate an whole project structure without having to write any CMakeLists.txt by your own.}
  spec.homepage      = "https://github.com/jonathangingras/ckick"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
