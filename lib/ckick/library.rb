# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/target"

module CKick

  # represents an library target (in respect to CMake add_library() command)
  class Library < Target

    # * +args+ - Target hash (directly a CKickfile library target element's hash parsed with keys as Symbol), must be a Hash
    # ====== CKick::Library specific input hash keys (in addition of CKick::Target ones)
    # * +:shared+ - whether or not this library should be a dynamic library (shared object) or a static library (archive)
    def initialize args={}
      super args

      @shared = args[:shared] || false
    end

    # converts to Hash (for CKickfile)
    def to_hash
      if @shared
        return super
      else
        return super.without(:shared)
      end
    end

    # CMakeLists content of the target
    def cmake
      res = []

      res << "add_library(#{@name}#{@shared ? " SHARED " : " "}#{@source.join(' ')})"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res.join("\n")
    end
  end

end
