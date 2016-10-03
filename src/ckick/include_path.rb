module CKick

  class IncludePath
    def initialize args
      @path = args[:path]
    end

    def to_s
      @path
    end

    def raw_flag
      "-I#{@path}"
    end

    def cmake
      %Q(include_directories(#{@path}))
    end
  end

end
