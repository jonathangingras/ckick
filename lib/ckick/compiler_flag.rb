# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# :nodoc:
module CKick

  #represents a compiler flag to pass to the compiler
  class CompilerFlag
    # raw flag
    attr_reader :content

    # * +args+ - Hash containing flag data as String
    # ==== Input hash keys
    # * +:flag+ - raw flag content, must be String
    def initialize args={}
      raise IllegalInitializationError, "No flag provided to compiler flag" unless args.is_a?(Hash) && !args.empty?
      flag = args[:flag] || nil
      raise BadFlagError, "Bad flag content provided to compiler flag" unless flag.is_a?(String) && !flag.empty?

      @content = args[:flag]
    end

    # converts to String, flag as is
    def to_s
      @content
    end

    # converts to hash element: String
    def to_hash_element
      @content
    end

    # raw flag
    def raw_flag
      @content
    end

    # overrides Object#eql? for uniqueness
    def eql? other
      @content.eql? other.content
    end

    # overrides Object#hash for uniqueness
    def hash
      @content.hash
    end
  end

end
