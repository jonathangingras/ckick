# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/executable"
require "ckick/library"
require "fileutils"
require "ckick/hashable"
require "ckick/path_delegate"

module CKick

  # Represents a project sub directory (in respect to CMake sub_directory() command)
  class SubDirectory
    include Hashable

    # directory name
    attr_reader :name

    # parent directory
    attr_reader :parent_dir

    # whether or not this directory has targets and a CMakeLists.txt
    attr_reader :has_cmake

    # Array of all targets ( CKick::Target ) contained in this subdirectory
    attr_reader :targets

    # subdirectories
    attr_reader :subdirs

    # * +args+ - SubDirectory hash (directly a CKickfile :subdirs Array element parsed with keys as Symbol), must be a Hash
    # ====== Input hash keys
    # * +:name+ - subdirectory name
    # * +:libraries+ - libraries built in this subdirectory (in respect to CMake add_library() command), Array of Hash each containing information for CKick::Library::new
    # * +:executables+ - executables built in this subdirectory (in respect to CMake add_executable() command), Array of Hash each containing information for CKick::Executable::new
    # * +:subdirs+ - recursive subdirectories (in respect to CMake subdirectory() command), must be a Array of Hash passed to CKick::SubDirectory::new
    # * +:has_cmake+ - whether or not this subdirectory has a CMakeLists.txt (consequently builds targets or not)
    # * +:install_dir+ - installation directory, relative to CMAKE_INSTALL_PREFIX, "" by default for no install
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

      @subdirs = []
      subdirs.each do |subdir|
        @subdirs << SubDirectory.new(subdir)
      end

      install_dir = args[:install_dir] || ""
      raise BadDirectoryNameError, "Bad directory name error, must be a String" unless install_dir.is_a?(String)
      @install_dir = install_dir

      @parent_dir = nil
    end

    # converts to String, subdirectory name as is
    def to_s
      @name
    end

    # converts to Hash (to CKickfile :subdirs element)
    def to_hash
      excluded_attributes = [:parent_dir, :targets]
      excluded_attributes << :has_cmake if @has_cmake == true
      output = to_no_empty_value_hash.without(*excluded_attributes)
      [[Executable, :executables], [Library, :libraries]].each do |klass, symbol|
        targets = @targets.select { |t| t.is_a?(klass) }.collect { |t| t.to_hash }
        output[symbol] = targets unless targets.empty?
      end
      output
    end

    # subdirectory path
    def path
      raise NoParentDirError, "sub directory #{@name} has no parent set" unless @parent_dir
      File.join(@parent_dir, @name)
    end

    # creates subdirectory structure
    #
    # this method is called recursively on subdirectories
    def create_structure
      PathDelegate.create_directory(path)

      if @has_cmake
        PathDelegate.write_file(path, "CMakeLists.txt", cmake)

        targets.each do |t|
          t.create_structure
        end
      end

      @subdirs.each do |subdir|
        subdir.create_structure
      end
    end

    # subdirectory CMakeLists.txt file content
    def cmake
      res = ''

      res << targets.collect { |t| t.cmake }.join("\n")

      unless @subdirs.empty?
        res << "\n"
        res << @subdirs.collect do |subdir|
          "add_subdirectory(#{subdir.name})"
        end.join("\n")
      end

      unless @install_dir.empty?
        res << %{install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} DESTINATION #{@install_dir} PATTERN "CMakeLists.txt" EXCLUDE)\n}
      end

      res
    end

    # sets parent directory path
    #
    # this method is called recursively on subdirectories
    def set_parent(parent_dir)
      @parent_dir = parent_dir

      targets.each do |t|
        t.__send__ :set_parent, path
      end

      @subdirs.each do |subdir|
        subdir.__send__ :set_parent, path
      end
    end

    # TODO doc + specs
    # add a sub directory, parent of passed object will be overridden to current object
    def add_subdirectory(subdir)
      raise "must be a CKick::SubDirectory" unless subdir.is_a?(SubDirectory)
      subdir.__send__ :set_parent, path
      @subdirs << subdir
    end

    # TODO doc + specs
    # add a target, parent of passed object will be overridden to current object
    def add_target(target)
      raise "must be a CKick::Target" unless lib.is_a?(Target)
      target.__send__ :set_parent, path
      @targets << target
    end

    # TODO doc + specs
    def find_target(name)
      targets.select { |t| t.name == name }.first_or_raise "no such CKick::Executable found"
    end

    private :set_parent
  end

end
