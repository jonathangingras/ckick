# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/plugin"
require "fileutils"

class GTest < CKick::Plugin
  LIBS_VARIABLE = "${GTEST_LIBRARIES}"

  def initialize args={}
    @optional = args[:optional] || false
    @resource_file = "build-gtest.cmake"
  end

  def cmake
    res = ''
    res << %Q(option(BUILD_TESTING OFF "whether to build tests or not")\n) \
        << "if(BUILD_TESTING)\n\t" if @optional

    res << "enable_testing()\n"
    res << "include(#{@resource_file})"

    res << "\nendif()" if @optional
    res
  end

  def call(project)
    file = File.new(File.join(project.root, @resource_file), 'w')
    file << File.new(File.join(File.dirname(__FILE__), "resource", @resource_file), 'r').read
    file.close
  end

  def include(project)
    res = []
    [
      File.join(project.build_dir, "gtest-prefix", "src", "gtest", "googletest", "include"),
      File.join(project.build_dir, "gtest-prefix", "src", "gtest", "googlemock", "include")
    ].each do |path|
      FileUtils.mkdir_p path
      res << CKick::IncludePath.new(path: path)
    end
    res
  end
end

module CKick
  class ConfigurationBuilder
    def gtest_executable(name, source, args={}, &block)
      args[:is_test] = true
      args[:libs] = ["${GTEST_LIBRARIES}"]
      args[:dependencies] = ["${GTEST_TARGET}"]
      executable(name, source, args, &block)
    end
  end
end
