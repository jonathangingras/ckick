require 'ckick/target'

module CKick

  class Executable < Target
    def cmake
      res = ''

      res << "add_executable(#{@name} #{@source_file.join(' ')})\n\n"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res
    end
  end

end
