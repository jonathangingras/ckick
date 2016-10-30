# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick

  class LibraryLink

    def initialize args={}
      name = args[:name] || ""
      raise CKick::IllegalInitializationError, "No name provided to library link" unless name.is_a?(String) && !name.empty?
      @name = name
    end

    def to_hash_element
      @name
    end

    def to_s
      @name
    end

    def raw_flag
      "-l#{@name}"
    end

    def cmake
      @name
    end
  end

end
