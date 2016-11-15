# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/compiler_flag"

module CKick

  # C++ compiler flag representation
  class CXXFlag < CompilerFlag

    # appends ${CMAKE_CXX_FLAGS} (CMake C++ compiler flags)
    def cmake
      %Q|set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} #{@content}")|
    end
  end

end
