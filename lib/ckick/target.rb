# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/nil_class"
require "ckick/library_link"
require "ckick/path_delegate"
require "ckick/hashable"

module CKick

  class Target
    include Hashable

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

      @parent_dir = nil
    end

    def to_hash
      to_no_empty_value_hash.without(:parent_dir)
    end

    def to_s
      @name
    end

    def paths
      raise NoParentDirError, "No parent directory has been set for target #{@name}" unless @parent_dir
      res = []
      @source.each do |source_file|
        res << File.join(@parent_dir, source_file)
      end
      res
    end

    def create_structure
      paths.each do |path|
        unless File.exist? path
          PathDelegate.touch_file(path)
        end
      end
    end

    private

    def set_parent(parent_dir)
      @parent_dir = parent_dir
    end
  end

end
