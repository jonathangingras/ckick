# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/library_link"
require "ckick/path_delegate"
require "ckick/hashable"

module CKick

  # common representation of targets to build, such as executables and libraries
  class Target
    include Hashable

    # target name for CMake
    attr_reader :name

    # * +args+ - Target hash (directly a CKickfile target element's hash parsed with keys as Symbol), must be a Hash
    # ====== Input hash keys
    # * +:name+ - name of the target
    # * +:source+ - either a String (single-source file) or Array of String (multiple source files)
    # * +:libs+ - names of the libraries to link to the target, must be Array of String
    # * +:install_dir+ - installation directory, relative to CMAKE_INSTALL_PREFIX, "" by default for no install
    # * +:dependencies+ - dependent cmake targets (strings), must be Array of String or single String
    def initialize args={}
      raise IllegalInitializationError unless args.is_a?(Hash) && !args.empty?

      name = args[:name] || ""
      raise NoNameError, "No target name given for target" unless name.is_a?(String) && !name.empty?
      @name = name

      source = args[:source] || []
      if source.is_a? Array
        raise NoSourceError, "No source file provided for target #{@name}" if source.empty?
        raise BadSourceError, "Bad source file names provided for target #{@name}: #{source}" unless source.select { |el| !el.is_a?(String) }.empty?
        @source = source
      elsif source.is_a? String
        @source = [source]
      else
        raise BadSourceError, "Bad source file name provided for target #{@name}"
      end

      @libs = []
      libs = args[:libs] || []
      if libs.is_a?(Array)
        raise BadLibError, "Bad library name provided for target #{@name}: #{libs}" unless libs.select { |el| !el.is_a?(String) }.empty?
        libs.each do |lib|
          @libs << LibraryLink.new(name: lib)
        end
      elsif libs.is_a?(String)
        @libs << LibraryLink.new(name: libs)
      else
        raise BadLibError, "Bad library name provided for target #{@name}: #{libs}"
      end

      install_dir = args[:install_dir] || ""
      raise BadDirectoryNameError, "Bad directory name error, must be a String" unless install_dir.is_a?(String)
      @install_dir = install_dir

      dependencies = args[:dependencies] || []
      dependencies = [dependencies] if dependencies.is_a?(String)
      raise BadTargetDependencyNameError, "Bad dependency target name error, must be an Array of String or single String" unless dependencies.select { |el| !el.is_a?(String) }.empty?
      @dependencies = dependencies

      @parent_dir = nil
    end

    # converts to Hash (for CKickfile)
    def to_hash
      to_no_empty_value_hash.without(:parent_dir)
    end

    # converts to String, the target's name as is
    def to_s
      @name
    end

    # Array of source file paths
    def paths
      raise NoParentDirError, "No parent directory has been set for target #{@name}" unless @parent_dir
      res = []
      @source.each do |source_file|
        res << File.join(@parent_dir, source_file)
      end
      res
    end

    # creates target's structure (each missing source file)
    def create_structure
      paths.each do |path|
        unless File.exist? path
          PathDelegate.touch_file(path)
        end
      end
    end

    # CMakeLists content of the target
    def cmake
      dependencies = @dependencies.empty? ? "" : %{add_dependencies(#{@name} #{@dependencies.join(' ')})}
      installation = @install_dir.empty? ? "" : %{install(TARGETS #{@name} DESTINATION #{@install_dir})}
      #[dependencies, installation].select { |s| !s.empty? }.join("\n")
      dependencies + installation
    end

    # set's parent directory
    def set_parent(parent_dir)
      @parent_dir = parent_dir
    end

    # TODO doc + specs
    def add_to_source(*source_files)
      source_files.each { |source_file| @source << source_file }
    end

    # TODO doc + specs
    def add_link(library_link)
      raise "argument is no CKick::LibraryLink" unless library_link.is_a?(LibraryLink)
      @libs << library_link
    end

    private :set_parent
  end

end
