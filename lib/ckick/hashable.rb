require "ckick/hash"
require "ckick/hash_elements"

module CKick
  module Hashable
    def to_hash
      a = {}
      instance_variables_as_key_values.each do |name, obj|
        a[name] = object_value(obj)
      end
      a
    end

    def to_no_empty_value_hash
      a = {}
      instance_variables_as_key_values.each do |name, obj|
        if !obj.respond_to?(:empty?) || (obj.respond_to?(:empty?) && !obj.empty?)
          a[name] = object_value(obj)
        end
      end
      a
    end

    private

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
  end
end
