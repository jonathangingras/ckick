module CKick

  class Path
    attr_reader :path

    def initialize args={}
      raise IllegalInitializationError, "needs :path parameter" unless args.is_a?(Hash) && args[:path].is_a?(String)
      raise NoSuchDirectoryError, "invalid path #{args[:path]}" unless Dir.exist?(args[:path])

      @path = args[:path]
    end

    def to_s
      @path
    end

    def to_hash_element
      @path
    end
  end

end
