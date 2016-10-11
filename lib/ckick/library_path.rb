require "ckick/path"

module CKick

  class LibraryPath < Path
    def raw_flag
      "-L#{@path}"
    end

    def cmake
      "link_directories(#{@path})"
    end
  end

end
