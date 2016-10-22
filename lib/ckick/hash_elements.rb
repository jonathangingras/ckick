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
    collect { |element| element.to_hash rescue element.to_hash_element }
  end
end

class NilClass
  def to_hash_element
    self
  end
end
