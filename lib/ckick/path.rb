module CKick

  class Path
    def initialize args={}
      raise IllegalInitializationError, "needs :path parameter" unless args.is_a?(Hash) && args[:path]
      raise NoSuchDirectoryError, "invalid path #{args[:path]}" unless Dir.exist?(args[:path])

      @path = args[:path]
    end

    def to_s
      @path
    end
  end

end
