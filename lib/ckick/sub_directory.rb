require 'ckick/nil_class'
require 'ckick/executable'
require "ckick/library"
require "fileutils"

module CKick

  class SubDirectory

    attr_reader :name, :parent_dir, :sub_directories, :has_cmake

    def initialize args={}
      name = args[:name]
      raise IllegalInitializationError, "no name provided to sub directory" unless name.is_a?(String) && !name.empty?
      libs = args[:libraries]
      raise IllegalInitializationError, ":libraries argument is not an Array" unless libs.is_a?(Array) || libs.nil?
      exes = args[:executables]
      raise IllegalInitializationError, ":executables argument is not an Array" unless exes.is_a?(Array) || exes.nil?
      subdirs = args[:subdirs]
      raise IllegalInitializationError, ":subdirs is not an Array" unless subdirs.is_a?(Array) || subdirs.nil?

      has_cmake = args[:has_cmake].nil? || args[:has_cmake]

      if (!exes.nil? || !libs.nil?) && !has_cmake
        raise BadSubDirectoryError, "A subdirectory not containing a CMakeLists cannot contain targets."
      end

      @name = name
      @has_cmake = has_cmake

      @targets = []
      libs.each do |lib|
        @targets << Library.new(lib)
      end
      exes.each do |exe|
        @targets << Executable.new(exe)
      end

      @sub_directories = []
      subdirs.each do |subdir|
        @sub_directories << SubDirectory.new(subdir)
      end

      @parent_dir = nil
    end

    def to_s
      @name
    end

    def path
      raise NoParentDirError, "sub directory #{@name} has no parent set" unless @parent_dir
      File.join(@parent_dir, @name)
    end

    def create_structure
      FileUtils.mkdir_p path

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

      res << @targets.collect { |t| t.cmake }.join("\n")

      unless @sub_directories.empty?
        res << "\n"
        res << @sub_directories.collect do |subdir|
          "add_subdirectory(#{subdir.name})"
        end.join("\n")
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
