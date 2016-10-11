require 'ckick/target'

module CKick

  class Library < Target
    def cmake
      res = []

      res << "add_library(#{@name} #{@source_file.join(' ')})"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res.join('\n')
    end
  end

end
