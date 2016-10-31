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

  # Project dependency settings, such as include path, library path, and compiler flags
  class Dependencies
    include Hashable

    # * +args+ - Dependencies hash (directly the CKickfile :dependencies element parsed with keys as Symbol), must be a Hash
    # ====== Input hash keys
    # * +:cflags+ - C language specific flags, for e.g. '-std=c89', '-Wall', etc., must be an Array of String
    # * +:cxxflags+ - C++ language specific flags, for e.g. '-std=c++11', '-fno-exceptions', etc., must be an Array of String
    # * +:include+ - Array of paths to append the include path (-I compiler option; include_directories() CMake command)
    # * +:lib+ - Array of paths to append the link path (-L compiler option; link_directories() CMake command)
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

    # converts to Hash (usable in CKickfile)
    def to_hash
      to_no_empty_value_hash
    end

    # CMakeLists's section content
    def cmake
      [@cflags, @cxxflags, @include, @lib].flatten(1).collect do |unit|
          unit.cmake
      end.join("\n")
    end

    # compiler flags in an Array
    def flags
      [@cflags, @cxxflags, @include, @lib].flatten(1).uniq.collect do |flag|
        flag.raw_flag
      end
    end

    # appends include path (-I) with +path+
    #
    # +path+ - include path, must be a CKick::IncludePath
    def add_include(path)
      raise BadIncludePathError, "path must be a CKick::IncludePath object" unless path.is_a?(IncludePath)
      @include << path unless @include.include?(path)
    end

    # appends link path (-L) with +path+
    #
    # +path+ - link path, must be a CKick::LibraryPath
    def add_lib(path)
      raise BadLibraryPathError, "path must be a CKick::LibraryPath object" unless path.is_a?(LibraryPath)
      @lib << path unless @lib.include?(path)
    end
  end

end
