module CKick

  class LibraryLink
    def initialize args
      @name = args[:name]
    end

    def to_s
      @name
    end

    def raw_flag
      "-l#{@name}"
    end

    def cmake
      @name
    end
  end

end
