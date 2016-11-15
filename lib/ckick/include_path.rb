# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/path"

module CKick

  #Represents a compiler include path (-I option or CMake include_directories() fonction)
  class IncludePath < Path

    #compiler flag as is
    def raw_flag
      "-I#{@path}"
    end

    #cmake code content
    def cmake
      %Q{include_directories(#{@path})}
    end
  end

end
