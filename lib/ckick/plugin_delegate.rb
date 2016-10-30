# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

module CKick

  module PluginDelegate

    def self.find(plugin)
      Object.const_get(plugin[:name]).new(plugin[:args] || {})
    end

  end

end
