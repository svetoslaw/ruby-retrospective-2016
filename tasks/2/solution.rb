class Hash
  def fetch_deep(path)
    first_element_key, split_path = path.split('.', 2)
    hash = self.keys_to_strings
    if split_path && hash[first_element_key]
      hash[first_element_key].fetch_deep(split_path) 
    else
      hash[first_element_key]
    end
  end

  def keys_to_strings
    result = {}
    self.each do |key, value|
      result[key.to_s] = value
    end
    result
  end

  def reshape(shape)
    shape.map do |key, value|
      if value.is_a?(Hash)
        [ key, self.reshape(value) ]
      else
        [ key, self.fetch_deep(value) ]
      end
    end.to_h
  end
end

class Array
  def reshape(shape)
    result = []
    self.each do |n|
      n = n.reshape(shape)
      result << n
    end
    result
  end

  def fetch_deep(path)
    first_element_key, split_path = path.split('.', 2)
    if split_path && hash[first_element_key.to_i]
      self[first_element_key.to_i].fetch_deep(split_path)
    else
      self[first_element_key.to_i]
    end
  end
end