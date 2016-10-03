require 'ckick/nil_class'
require 'ckick/library_link'

module CKick

  class Executable
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

    def set_parent(parent_dir)
      @parent_dir = parent_dir
    end

    private :set_parent

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

    def cmake
      res = ''

      res << "add_executable(#{@name} #{@source_file.join(' ')})\n\n"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res
    end
  end

end
