# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/target"

module CKick

  # represents an executable target (in respect to CMake add_executable() command)
  class Executable < Target

    # CMakeLists content of the target
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
