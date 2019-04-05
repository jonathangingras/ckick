# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/dependencies"
require "ckick/sub_directory"
require "ckick/variable"
require "ckick/hashable"
require "ckick/path_delegate"
require "ckick/plugin_delegate"

module CKick

  # This class represents a CMake project (as a main CMakeLists)
  class Project
    include Hashable

    # each project CKick::SubDirectory
    attr_reader :subdirs

    # project CKick::Dependencies
    attr_reader :dependencies

    # project root directory, relative to CKickfile
    attr_reader :root

    # project root directory absolute path, not saved in CKickfile
    attr_reader :absolute_root

    # project build directory
    attr_reader :build_dir

    # project name match pattern
    NAME_MATCH = /^[[A-Z][a-z]_[0-9]]+$/

    # version match
    CMAKE_VERSION_MATCH = /^[0-9](\.[0-9]){0,2}$/

    # * +args+ - project hash (directly the CKickfile parsed with keys as Symbol), must be a Hash
    # ====== Input hash keys
    # * +:name+ - project name, must respect NAME_MATCH
    # * +:cmake_min_version+ - CMake minimum version (must be String), defaults to '3', must match CMAKE_VERSION_MATCH
    # * +:root+ - Project root directory, usually '.'
    # * +:build_dir+ - Project build directory, usually 'build'
    # * +:subdirs+ - subdirectories (in respect to CMake subdirectory() command), must be a Array of Hash passed to SubDirectory::new
    # * +:plugins+ - Array of Hash containing {:name => CKick::Plugin class name, :args => args for respective :initialize method }
    def initialize args
      name = args[:name] || ""
      raise IllegalInitializationError, "name must be a non-empty string only containing alphanumeric characters" unless name.is_a?(String) && name.match(NAME_MATCH)

      min_v = args[:cmake_min_version] || '3'
      variables = args[:variables] || []

      raise IllegalInitializationError, "cmake_min_version is non-String" unless min_v.is_a?(String)
      raise IllegalInitializationError, "cmake_min_version has non working pattern x or x.y or x.y.z" unless min_v.match(CMAKE_VERSION_MATCH)

      root = args[:root] || ""
      raise IllegalInitializationError, "root directory is non-String" unless root.is_a?(String)
      raise IllegalInitializationError, "root directory is empty" if root.empty?

      build_dir = args[:build_dir] || ""
      raise IllegalInitializationError, "build directory is non-String" unless build_dir.is_a?(String)
      raise IllegalInitializationError, "build directory is empty" if build_dir.empty?
      raise IllegalInitializationError, "varibales must be CKick::Variable" unless variables.is_a?(Array) && variables.select { |v| !v.is_a?(::CKick::Variable) }.empty?

      @name = name
      @cmake_min_version = min_v
      @root = root
      @absolute_root = args[:absolute_root] || File.absolute_path(@root)
      @build_dir = build_dir
      @dependencies = Dependencies.new(args[:dependencies] || {})
      @variables = variables

      @plugins = []
      args[:plugins].each do |plugin|
        @plugins << PluginDelegate.find(plugin)
      end

      @subdirs = []
      args[:subdirs].each do |subdir|
        @subdirs << SubDirectory.new(subdir)
      end

      @subdirs_initiated = false
      init_subdirs
    end

    # set the project name, must match NAME_MATCH
    def set_name(name)
      raise BadProjectNameError, "project name must be a non-empty alphanumeric string" unless name.is_a?(String) && name.match(NAME_MATCH)
      @name = name
    end

    # convert to String -> the project name as is
    def to_s
      @name
    end

    # convert to Hash (to CKickfile)
    def to_hash
      to_no_empty_value_hash.without(:subdirs_initiated, :absolute_root)
    end

    # project root directory path
    def path
      @root
    end

    # TODO doc + specs
    def add_variable(variable)
      raise "variable must be a CKick::Variable" unless variable.is_a?(::CKick::Variable)
      @variables << variable
    end

    # creates the project CMake structure
    def create_structure
      raise "SubDirectories have not been initiated" unless @subdirs_initiated

      run_plugins

      PathDelegate.create_directory path
      PathDelegate.write_file(path, "CMakeLists.txt", cmake)

      @subdirs.each do |subdir|
        subdir.create_structure
      end

      call_plugins
    end

    # register an additionnal CKick::Plugin or block
    def register_plugin(plugin=nil, &block)
      raise ArgumentError, "" unless plugin.is_a?(::CKick::Plugin) || block

      if plugin.is_a?(::CKick::Plugin)
        @plugins << plugin
      elsif plugin.nil? && block
        @plugins << block
      end
    end

    # main project's CMakeLists.txt content
    def cmake
      append_plugin_paths

      res = "project(#{@name})\n" +
            "cmake_minimum_required(VERSION #{@cmake_min_version})\n\n"

      res << "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)\n" \
             "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)\n" \
             "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)\n\n"

      res << @dependencies.cmake << "\n\n"

      res << plugins_cmake << "\n\n" unless @plugins.empty?

      @subdirs.each do |dir|
        res << "add_subdirectory(#{dir.name})\n" if dir.has_cmake
      end

      res
    end

    private

    # called at the end of Project::new
    def init_subdirs
      @subdirs.each do |subdir|
        subdir.__send__ :set_parent, path
      end

      @subdirs_initiated = true
    end

    # appends include path and library path by each CKick::Plugin#include and CKick::Plugin#lib
    def append_plugin_paths
      @plugins.each do |plugin|
        plugin.include(self).each do |path|
          @dependencies.add_include path
        end
        plugin.lib(self).each do |path|
          @dependencies.add_lib path
        end
      end
    end

    # ran before structure creation (calls each CKick::Plugin#run)
    def run_plugins
      @plugins.each do |plugin|
        plugin.run(self) if plugin.respond_to? :run
      end
    end

    # ran after structure creation (calls each CKick::Plugin#call)
    def call_plugins
      @plugins.each do |plugin|
        plugin.call self
      end
    end

    # plugins CMakeLists.txt content section in main CMakeLists.txt content
    def plugins_cmake
      res = "##ckick plugins section##\n"

      def plugin_name(plugin) #:nodoc:
        if plugin.respond_to?(:name)
          return plugin.name
        else
          return "<inline plugin>"
        end
      end

      @plugins.each do |plugin|
        res << "#ckick plugin: #{plugin_name(plugin)}\n"
        res << plugin.cmake << "\n" if plugin.respond_to? :cmake
      end

      res << "##end plugin section##"
    end

    # TODO doc + specs
    def find_subdirectory!(path)
      find_subdirectory_private(path, true)
    end

    # TODO doc + specs
    def find_subdirectory(path)
      find_subdirectory_private(path, false)
    end

    def find_subdirectory_private(path, create_when_missing)
      path_lvls = Pathname.new(File.absolute_path(path)).relative_path_from(Pathname.new(absolute_root)).each_filename.to_a

      dir_ptr = self
      while path_lvls.length != 0
        catch :found do
          dir_ptr.subdirs.each do |dir|
            if dir.name == path_lvls[0]
              dir_ptr = dir
              path_lvls = path_lvls[1..-1]
              throw :found
            end
          end

          # not found
          raise "no such directory taken in charge by project: `#{path_lvls[0]}'" unless create_when_missing
          new_dir = CKick::SubDirectory.new(name: path_lvls[0])
          dir_ptr.add_subdirectory(new_dir)
          dir_ptr = new_dir
          path_lvls = path_lvls[1..-1]
        end
      end

      dir_ptr
    end

    private :find_subdirectory_private
  end
end
