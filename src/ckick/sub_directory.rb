require 'ckick/nil_class'
require 'ckick/dir'
require 'ckick/executable'
require "ckick/library"

module CKick

  class SubDirectory

    attr_reader :name, :parent_dir, :sub_directories, :has_cmake

    def initialize args
      @name = args[:name]

      @has_cmake = args[:has_cmake].nil? || args[:has_cmake]

      @targets = []
      args[:libraries].each do |lib|
        @targets << Library.new(lib)
      end
      args[:executables].each do |exe|
        @targets << Executable.new(exe)
      end

      if !@targets.empty? && !@has_cmake
        raise "A subdirectory not containing a CMakeLists cannot contain targets."
      end

      @sub_directories = []
      args[:subdirs].each do |subdir|
        @sub_directories << SubDirectory.new(subdir)
      end

      @parent_dir = nil
    end

    def to_s
      @name
    end

    def path
      File.join(@parent_dir, @name)
    end

    def create_structure
      Dir.mkdirp path

      if @has_cmake
        file = File.new(File.join(path, "CMakeLists.txt"), 'w')
        file << cmake
        file.close

        @targets.each do |exe|
          exe.create_structure
        end
      end

      @sub_directories.each do |subdir|
        subdir.create_structure
      end
    end

    def cmake
      res = ''

      @targets.each do |exe|
        res << exe.cmake << "\n"
      end

      res << "\n"

      @sub_directories.each do |subdir|
        res << "add_subdirectory(#{subdir.name})\n"
      end

      res
    end

    private

    def set_parent(parent_dir)
      @parent_dir = parent_dir

      @targets.each do |exe|
        exe.__send__ :set_parent, path
      end

      @sub_directories.each do |subdir|
        subdir.__send__ :set_parent, path
      end
    end
  end

end