require 'ckick/target'

module CKick

  class Executable < Target
    def cmake
      res = []

      res << "add_executable(#{@name} #{@source.join(' ')})"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res.join("\n")
    end
  end

end
