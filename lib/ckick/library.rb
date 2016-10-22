require 'ckick/target'

module CKick

  class Library < Target
    def initialize args={}
      super args

      @shared = args[:shared] || false
    end

    def to_hash
      if @shared
        return super
      else
        return super.without(:shared)
      end
    end

    def cmake
      res = []

      res << "add_library(#{@name}#{@shared ? " SHARED " : " "}#{@source.join(' ')})"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res.join("\n")
    end
  end

end
