# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/path"

module CKick

  # Represents a library link path (in respect to compiler -L option and CMake link_directories() fonction)
  class LibraryPath < Path

    #compiler flag as is
    def raw_flag
      "-L#{@path}"
    end

    #cmake code content
    def cmake
      "link_directories(#{@path})"
    end
  end

end
