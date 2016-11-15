# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# :nodoc:
module CKick

  # Represents a file system path, it must exist
  class Path
    attr_reader :path

    #initializes path, path must exist
    def initialize args={}
      raise IllegalInitializationError, "needs :path parameter" unless args.is_a?(Hash) && args[:path].is_a?(String)
      raise NoSuchDirectoryError, "invalid path #{args[:path]}" unless Dir.exist?(args[:path])

      @path = args[:path]
    end

    #returns path as is
    def to_s
      @path
    end

    #converts to hash-serializable element
    def to_hash_element
      @path
    end
  end

end
