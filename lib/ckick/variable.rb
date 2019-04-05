# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick

  class Variable
    attr_reader :name
    attr_reader :value

    class Name
      def initialize(name)
        raise "name must be String without inner spaces" unless name.is_a?(String) && name.split(' ').length != 1
        @name = name
      end

      def to_s
        "${#{@name}}"
      end
    end

    def initialize(args={})
      raise "name must be String or CKick::Variable::Name" unless args[:name].is_a?(VariableName) || args[:name].is_a?(String)
      raise "value must be String or nil" unless args[:value].is_a?(String) || args.nil?

      @name = args[:name].is_a?(String) ? CKick::Variable::Name.new(args[:name]) : args[:name]
      @value = args[:value] || ""
    end

    def cmake
      "set(#{@name} #{@value})"
    end
  end

end
