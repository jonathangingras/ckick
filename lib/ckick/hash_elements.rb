# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# :nodoc:
class String
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end

# :nodoc:
class Fixnum
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end

# :nodoc:
class Float
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end

# :nodoc:
class TrueClass
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end

# :nodoc:
class FalseClass
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end

# :nodoc:
class Array
  #converts to hash-serializable value
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

# :nodoc:
class NilClass
  #converts to hash-serializable value
  def to_hash_element
    self
  end
end
