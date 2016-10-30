# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "json"

module CKick
  def self.load_ckickfile(dir=Dir.pwd, filename="CKickfile")
    JSON.parse(File.read(File.join(dir, filename)), symbolize_names: true)
  end
end
