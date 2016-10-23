class String
  def to_hash_element
    self
  end
end

class Fixnum
  def to_hash_element
    self
  end
end

class Float
  def to_hash_element
    self
  end
end

class TrueClass
  def to_hash_element
    self
  end
end

class FalseClass
  def to_hash_element
    self
  end
end

class Array
  def to_hash_element
    collect do |element|
      if element.respond_to?(:to_hash)
        element.to_hash
      else
        element.to_hash_element
      end
    end
  end
end

class NilClass
  def to_hash_element
    self
  end
end
