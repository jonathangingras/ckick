module CKick

  class LibraryPath
    def initialize args
      @path = args[:path]
    end

    def to_s
      @path
    end

    def raw_flag
      "-L#{@path}"
    end

    def cmake
      "link_directories(#{@path})"
    end
  end

end
