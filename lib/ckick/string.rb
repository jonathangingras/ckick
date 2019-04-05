# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class String
  def has_prefix?(prefix)
    length > prefix.length && self[0..prefix.length] == prefix
  end

  def to_command_sym
    has_prefix?("cmd:") ? self[4..-1].to_sym : to_sym
  end
end
