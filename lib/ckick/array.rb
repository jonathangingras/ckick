# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/hash"

class Array
  def array_aware_deep_transform_keys(&block)
    result = []
    each do |value|
      if value.is_a?(Hash) || value.is_a?(Array)
        result << value.array_aware_deep_transform_keys(&block)
      else
        result << value
      end
    end
    result
  end
end
