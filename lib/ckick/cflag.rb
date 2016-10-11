require 'ckick/compiler_flag'

module CKick

  class CFlag < CompilerFlag
    def cmake
      %Q(set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} #{@content}"))
    end
  end

end
