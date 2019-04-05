# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/hash"

# :nodoc:
class Array
  # transforms any Hash key recursively
  # * +block+ - transform operation
  # TODO doc + specs
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

  # returns first element or raises if empty
  # * +message_or_class+ - class of the exception to raise or a message string if default exception class is wanted
  # * +message_if_class+ - message string argument if +message_or_class+ is an exception class
  # TODO doc + specs
  def first_or_raise(message_or_class, message_if_class=nil)
    result = first
    if message_if_class.nil?
      raise message_or_class if result.nil?
    else
      raise message_or_class, message_if_class if result.nil?
    end
    result
  end
end
