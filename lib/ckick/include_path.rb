require "ckick/path"

module CKick

  class IncludePath < Path
    def raw_flag
      "-I#{@path}"
    end

    def cmake
      %Q{include_directories(#{@path})}
    end
  end

end
