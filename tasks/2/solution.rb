class Hash
  def fetch_deep(path)
    first_element, split_path = path.split('.', 2)
    first_element = first_element.to_sym if self[first_element.to_sym]
    if split_path && self[first_element]
      self[first_element].fetch_deep(split_path) 
    else
      self[first_element]
    end
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
    first_element, split_path = path.split('.', 2)
    first_element = first_element.to_i
    if split_path && hash[first_element]
      self[first_element].fetch_deep(split_path)
    else
      self[first_element]
    end
  end
end