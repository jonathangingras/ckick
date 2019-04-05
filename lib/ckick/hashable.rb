# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require "ckick/hash"
require "ckick/hash_elements"

module CKick

  # mixin enabling hash serialization
  module Hashable

    # transforms object to Hash such that { :instance_variable => value }
    def to_hash
      a = {}
      instance_variables_as_key_values.each do |name, obj|
        a[name] = object_value(obj)
      end
      a
    end

    # transforms object to Hash such that { :instance_variable => value }, excluding any pair where value responds +true+ to :empty? method
    def to_no_empty_value_hash
      a = {}
      instance_variables_as_key_values.each do |name, obj|
        if !obj.respond_to?(:empty?) || (obj.respond_to?(:empty?) && !obj.empty?)
          a[name] = object_value(obj)
        end
      end
      a
    end

    def instance_variables_as_key_values
      instance_variables.collect do |att|
        [att[1..-1].to_sym, instance_variable_get(att.to_sym)]
      end
    end

    def object_value(obj)
      if obj.respond_to?(:to_hash)
        return obj.to_hash
      else
        return obj.to_hash_element
      end
    end

    private :instance_variables_as_key_values, :object_value
  end
end
