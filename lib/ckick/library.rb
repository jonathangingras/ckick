# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/target"

module CKick

  class Library < Target
    def initialize args={}
      super args

      @shared = args[:shared] || false
    end

    def to_hash
      if @shared
        return super
      else
        return super.without(:shared)
      end
    end

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
