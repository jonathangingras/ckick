require 'ckick/nil_class'
require 'ckick/cflag'
require 'ckick/cxxflag'
require 'ckick/include_path'
require 'ckick/library_path'

module CKick

  class Dependencies
    def initialize args={}
      raise IllegalInitializationError unless args.is_a?(Hash)

      cflags = args[:cflags] || []
      raise IllegalInitializationError, "cflags provided to dependencied is not an Array" unless cflags.is_a?(Array)
      @cflags = cflags.collect do |flag|
        CFlag.new(flag: flag)
      end

      cxxflags = args[:cxxflags] || []
      raise IllegalInitializationError, "cxxflags provided to dependencied is not an Array" unless cxxflags.is_a?(Array)
      @cxxflags = cxxflags.collect do |flag|
        CXXFlag.new(flag: flag)
      end

      includes = args[:include] || []
      raise IllegalInitializationError, "include provided to dependencied is not an Array" unless includes.is_a?(Array)
      @includes = includes.collect do |include|
        IncludePath.new(path: include)
      end

      libs = args[:lib] || []
      raise IllegalInitializationError, "lib provided to dependencied is not an Array" unless libs.is_a?(Array)
      @lib = libs.collect do |lib|
        LibraryPath.new(path: lib)
      end
    end

    def cmake
      [@cflags, @cxxflags, @includes, @lib].flatten(1).collect do |unit|
          unit.cmake
      end.join("\n")
    end

    def flags
      [@cflags, @cxxflags, @includes, @lib].flatten(1).uniq.collect do |flag|
        flag.raw_flag
      end
    end

    def add_include(path)
      raise BadIncludePathError, "path must be a CKick::IncludePath object" unless path.is_a?(IncludePath)
      @includes << path
    end

    def add_lib(path)
      raise BadLibraryPathError, "path must be a CKick::LibraryPath object" unless path.is_a?(LibraryPath)
      @lib << path
    end
  end

end
