require 'ckick/nil_class'
require 'ckick/library_link'

module CKick

  class Target
    def initialize args
      if args[:source].is_a? Array
        @source_file = args[:source]
      else
        @source_file = [args[:source]]
      end

      @name = args[:name]

      @libs = []
      args[:libs].each do |lib|
        @libs << LibraryLink.new(name: lib)
      end

      @parent_dir = nil
    end

    def to_s
      @name
    end

    def paths
      res = []
      @source_file.each do |source_file|
        res << File.join(@parent_dir, source_file)
      end
      res
    end

    def create_structure
      paths.each do |path|
        unless File.exist? path
          File.new(path, 'w').close
        end
      end
    end

    private

    def set_parent(parent_dir)
      @parent_dir = parent_dir
    end
  end

end
