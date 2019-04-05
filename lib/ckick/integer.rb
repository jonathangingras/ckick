# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# :nodoc:
class Integer
  # TODO doc + specs
  def is_last?(ary)
    raise "not an Array" unless ary.is_a?(Array)
    self == ary.length - 1
  end
end
