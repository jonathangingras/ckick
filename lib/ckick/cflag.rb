# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/compiler_flag"

module CKick

  # C compiler flag representation
  class CFlag < CompilerFlag

    # appends ${CMAKE_C_FLAGS} (CMake C compiler flags)
    def cmake
      %Q|set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} #{@content}")|
    end
  end

end
