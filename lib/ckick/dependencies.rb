# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/cflag"
require "ckick/cxxflag"
require "ckick/include_path"
require "ckick/library_path"
require "ckick/hashable"

module CKick

  class Dependencies
    include Hashable

    def initialize args={}
      raise IllegalInitializationError unless args.is_a?(Hash)

      cflags = args[:cflags] || []
      raise IllegalInitializationError, "cflags provided to dependencies is not an Array" unless cflags.is_a?(Array)
      @cflags = cflags.collect do |flag|
        CFlag.new(flag: flag)
        end

      cxxflags = args[:cxxflags] || []
      raise IllegalInitializationError, "cxxflags provided to dependencied is not an Array" unless cxxflags.is_a?(Array)
      @cxxflags = cxxflags.collect do |flag|
        CXXFlag.new(flag: flag)
      end

      includes = args[:include] || []
      raise IllegalInitializationError, "include provided to dependencies is not an Array" unless includes.is_a?(Array)
      @include = includes.collect do |include|
        IncludePath.new(path: include)
      end

      libs = args[:lib] || []
      raise IllegalInitializationError, "lib provided to dependencies is not an Array" unless libs.is_a?(Array)
      @lib = libs.collect do |lib|
        LibraryPath.new(path: lib)
      end
    end

    def to_hash
      to_no_empty_value_hash
    end

    def cmake
      [@cflags, @cxxflags, @include, @lib].flatten(1).collect do |unit|
          unit.cmake
      end.join("\n")
    end

    def flags
      [@cflags, @cxxflags, @include, @lib].flatten(1).uniq.collect do |flag|
        flag.raw_flag
      end
    end

    def add_include(path)
      raise BadIncludePathError, "path must be a CKick::IncludePath object" unless path.is_a?(IncludePath)
      @include << path unless @include.include?(path)
    end

    def add_lib(path)
      raise BadLibraryPathError, "path must be a CKick::LibraryPath object" unless path.is_a?(LibraryPath)
      @lib << path unless @lib.include?(path)
    end
  end

end
