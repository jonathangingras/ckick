require 'ckick/compiler_flag'

module CKick

  class CXXFlag < CompilerFlag
    def cmake
      %Q(set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} #{@content}"))
    end
  end

end
