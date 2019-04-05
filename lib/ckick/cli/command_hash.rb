# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick
  module CLI

    class CommandHash
      def initialize(args={})
        @commands = args
      end

      def has_command?(cmd)
        return @commands.include?(cmd.to_command_sym)
      end

      def [](cmd)
        @commands[cmd.to_command_sym]
      end
    end

  end
end
