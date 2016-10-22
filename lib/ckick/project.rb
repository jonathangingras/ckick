require 'ckick/nil_class'
require 'ckick/dir'
require 'ckick/dependencies'
require 'ckick/sub_directory'
require "ckick/hashable"
require "pathname"

module CKick

  class Project
    include Hashable
    attr_reader :sub_directories, :dependencies, :root, :build_dir

    def initialize args
      @name = args[:name]

      @subdirs_initiated = false

      if args[:cmake_min_version].nil?
        @cmake_min_version = '3'
      else
        @cmake_min_version = args[:cmake_min_version]
      end

      root = args[:root] || Dir.pwd
      @root = Pathname.new(File.absolute_path(root)).relative_path_from(Pathname.pwd).to_s

      @build_dir = args[:build_dir] || 'build'

      @dependencies = Dependencies.new(args[:dependencies])

      @plugins = []
      args[:plugins].each do |plugin|
        @plugins << Object.const_get(plugin[:name]).new(plugin[:args] || {})
      end

      @subdirs = []
      args[:subdirs].each do |subdir|
        @subdirs << SubDirectory.new(subdir)
      end

      init_subdirs
    end

    def set_name(name)
      raise BadProjectNameError, "project name must be a non-empty alphanumeric string" unless name.is_a?(String) && name.match(/^[[A-z][0-9]]+$/)
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

      append_plugin_paths
      run_plugins

      Dir.mkdirp path
      file = File.new(File.join(path, "CMakeLists.txt"), 'w')
      file << cmake
      file.close

      @subdirs.each do |subdir|
        subdir.create_structure
      end

      call_plugins
    end

    def register_plugin(plugin=nil, &block)
      if plugin
        @plugins << plugin
      else
        @plugins << block
      end
    end

    def cmake
      res = "project(#{@name})\n" +
            "cmake_minimum_required(VERSION #{@cmake_min_version})\n\n"

      res << "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)\n" \
             "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)\n" \
             "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)\n\n"

      res << @dependencies.cmake

      res << plugins_cmake unless @plugins.empty?

      @subdirs.each do |dir|
        res << "add_subdirectory(#{dir.name})\n" unless !dir.has_cmake
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
        plugin.run self if plugin.class.method_defined? :run
      end
    end

    def call_plugins
      @plugins.each do |plugin|
        plugin.call self
      end
    end

    def plugins_cmake
      res = ''
      res << "\n##ckick plugins section##\n"

      def plugin_name(plugin)
        if plugin.is_a? ::CKick::Plugin
          return plugin.name
        else
          return "<inline plugin>"
        end
      end

      @plugins.each do |plugin|
        res << "#ckick plugin: #{plugin_name(plugin)}\n"
        res << plugin.cmake if plugin.class.method_defined? :cmake
        res << "\n"
      end

      res << "##end plugin section##\n" << "\n"
    end
  end

end
