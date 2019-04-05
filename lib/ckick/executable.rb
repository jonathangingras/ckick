# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/target"

module CKick

  # represents an executable target (in respect to CMake add_executable() command)
  class Executable < Target
    def initialize args={}
      super(args)
      raise BadTestDefinitionError, "is_test must be a boolean" if (!args[:is_test].nil? && !(args[:is_test].is_a?(TrueClass) || args[:is_test].is_a?(FalseClass)))
      @is_test = args[:is_test] || false
    end

    def to_hash
      return super.to_hash if @is_test
      super.to_hash.without(:is_test)
    end

    # CMakeLists content of the target
    def cmake
      res = []

      res << "add_executable(#{@name} #{@source.join(' ')})"

      unless @libs.empty?
        res << "target_link_libraries(#{@name} #{@libs.join(' ')})"
      end

      res << super unless super.empty?

      res << "add_test(#{@name} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/#{@name})" if @is_test

      res.join("\n")
    end
  end

end
