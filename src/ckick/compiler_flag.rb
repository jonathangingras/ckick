module CKick

  class CompilerFlag
    attr_reader :content

    def initialize args
      @content = args[:flag]
    end

    def to_s
      @content
    end

    def raw_flag
      @content
    end

    def eql? other
      @content.eql? other.content
    end

    def hash
      @content.hash
    end
  end

end
