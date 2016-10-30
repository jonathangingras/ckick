# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/dependencies"
require "ckick/sub_directory"
require "ckick/hashable"
require "ckick/path_delegate"
require "ckick/plugin_delegate"

module CKick

  class Project
    include Hashable
    attr_reader :subdirs, :dependencies, :root, :build_dir

    NAME_MATCH = /^[[A-Z][a-z]_[0-9]]+$/
    CMAKE_VERSION_MATCH = /^[0-9](\.[0-9]){0,2}$/

    def initialize args
      name = args[:name] || ""
      raise IllegalInitializationError, "name must be a non-empty string only containing alphanumeric characters" unless name.is_a?(String) && name.match(NAME_MATCH)

      min_v = args[:cmake_min_version] || '3'
      raise IllegalInitializationError, "cmake_min_version is non-String" unless min_v.is_a?(String)
      raise IllegalInitializationError, "cmake_min_version has non working pattern x or x.y or x.y.z" unless min_v.match(CMAKE_VERSION_MATCH)

      root = args[:root] || ""
      raise IllegalInitializationError, "root directory is non-String" unless root.is_a?(String)
      raise IllegalInitializationError, "root directory is empty" if root.empty?

      build_dir = args[:build_dir] || ""
      raise IllegalInitializationError, "build directory is non-String" unless build_dir.is_a?(String)
      raise IllegalInitializationError, "build directory is empty" if build_dir.empty?

      @name = name
      @cmake_min_version = min_v
      @root = root
      @build_dir = build_dir
      @dependencies = Dependencies.new(args[:dependencies] || {})

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

    def set_name(name)
      raise BadProjectNameError, "project name must be a non-empty alphanumeric string" unless name.is_a?(String) && name.match(NAME_MATCH)
      @name = name
    end

    def to_s
      @name
    end

    def to_hash
      to_no_empty_value_hash.without(:subdirs_initiated)
    end

    def path
      @root
    end

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

    def register_plugin(plugin=nil, &block)
      raise ArgumentError, "" unless plugin.is_a?(::CKick::Plugin) || block

      if plugin.is_a?(::CKick::Plugin)
        @plugins << plugin
      elsif plugin.nil? && block
        @plugins << block
      end
    end

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

    def init_subdirs
      @subdirs.each do |subdir|
        subdir.__send__ :set_parent, path
      end

      @subdirs_initiated = true
    end

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

    def run_plugins
      @plugins.each do |plugin|
        plugin.run(self) if plugin.respond_to? :run
      end
    end

    def call_plugins
      @plugins.each do |plugin|
        plugin.call self
      end
    end

    def plugins_cmake
      res = "##ckick plugins section##\n"

      def plugin_name(plugin)
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
  end

end
