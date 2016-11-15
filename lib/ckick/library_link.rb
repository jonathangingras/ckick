# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# :nodoc:
module CKick

  # Represents a library link
  # (-l compiler option or library name to be passed to CMake target_link_libraries() function)
  class LibraryLink

    # initializes object with an Hash
    # hash keys:
    # * +:name+ - library name (lib#{name}.a/.so) as is
    def initialize args={}
      name = args[:name] || ""
      raise CKick::IllegalInitializationError, "No name provided to library link" unless name.is_a?(String) && !name.empty?
      @name = name
    end

    # converts to hashable element
    # name as is
    def to_hash_element
      @name
    end

    # converts to String
    # name as is
    def to_s
      @name
    end

    # corresponding compiler link flag (-l option)
    def raw_flag
      "-l#{@name}"
    end

    # cmake code content (only library name, not command)
    def cmake
      @name
    end
  end

end
