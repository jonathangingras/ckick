# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/array"

# :nodoc:
class Hash
  # transforms keys recursively
  # * +block+ - transform operation
  # TODO doc + specs
  def array_aware_deep_transform_keys(&block)
    result = {}
    each do |key, value|
      new_key = yield(key)

      if value.is_a?(Hash) || value.is_a?(Array)
        result[new_key] = value.array_aware_deep_transform_keys(&block)
      else
        result[new_key] = value
      end
    end
    result
  end

  # transforms each String-key to Symbol-key
  # TODO doc + specs
  def array_aware_deep_symbolize_keys
    array_aware_deep_transform_keys { |key| key.to_sym rescue key }
  end

  # copy of the hash without pairs of +keys+
  # TODO doc + specs
  def without(*keys)
    dup.without!(*keys)
  end

  # removes each pair of +keys+
  # TODO doc + specs
  def without!(*keys)
    reject! { |key| keys.include?(key) }
  end
end
