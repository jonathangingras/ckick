require 'ckick/nil_class'
require 'ckick/cflag'
require 'ckick/cxxflag'
require 'ckick/include_path'
require 'ckick/library_path'

module CKick

  class Dependencies
    def initialize args
      @cflags = []
      args[:cflags].each do |flag|
        @cflags << CFlag.new(flag: flag)
      end

      @cxxflags = []
      args[:cxxflags].each do |flag|
        @cxxflags << CXXFlag.new(flag: flag)
      end

      @includes = []
      args[:include].each do |include|
        @includes << IncludePath.new(path: include)
      end

      @lib = []
      args[:lib].each do |lib|
        @lib << LibraryPath.new(path: lib)
      end
    end

    def cmake
      res = ''
      [@cflags, @cxxflags, @includes, @lib].flatten(1).each do |unit|
          res << unit.cmake << "\n"
      end
      res
    end

    def flags
      res = []
      [@cflags, @cxxflags, @includes, @lib].flatten(1).uniq.each do |flag|
        res << flag.raw_flag
      end
      res
    end

    def add_include(path)
      raise "path must be a CKick::IncludePath object" unless path.is_a? IncludePath
      @includes << path
    end

    def add_lib(path)
      raise "path must be a CKick::LibraryPath object" unless path.is_a? LibraryPath
      @lib << path
    end
  end

end
