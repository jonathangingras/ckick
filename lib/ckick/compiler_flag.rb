# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick

  class CompilerFlag
    attr_reader :content

    def initialize args={}
      raise IllegalInitializationError, "No flag provided to compiler flag" unless args.is_a?(Hash) && !args.empty?
      flag = args[:flag] || nil
      raise BadFlagError, "Bad flag content provided to compiler flag" unless flag.is_a?(String) && !flag.empty?

      @content = args[:flag]
    end

    def to_s
      @content
    end

    def to_hash_element
      @content
    end

    def raw_flag
      @content
    end

    def eql? other
      @content.eql? other.content
    end

    def hash
      @content.hash
    end
  end

end
