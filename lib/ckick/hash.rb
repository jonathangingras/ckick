require "ckick/array"

class Hash
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

  def array_aware_deep_symbolize_keys
    array_aware_deep_transform_keys{ |key| key.to_sym rescue key }
  end
end
