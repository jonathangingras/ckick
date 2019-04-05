# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick
  #:nodoc:
  module CLI

    # command option
    class Option
      attr_reader :name, :description, :available_arguments

      def initialize(args={})
        name = args[:name]
        description = args[:description] || ''
        available_arguments = args[:available_arguments] || {}

        raise CKick::IllegalInitializationError, "name must be a String" unless name.is_a?(String) && !name.empty?
        @name = name

        raise CKick::IllegalInitializationError, "description must be a String" unless description.is_a?(String)
        @description = description

        raise CKick::IllegalInitializationError, "available_arguments must be a Hash containing only Symbol => String pairs" unless available_args_ok(available_arguments)
        @available_arguments = available_arguments
      end

      private

      def available_args_ok(arguments)
        return false unless arguments.is_a?(Hash)

        arguments.keys.each do |k|
          return false unless k.is_a?(Symbol) && arguments[k].is_a?(String)
        end

        true
      end
    end

  end
end
