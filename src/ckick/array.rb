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
