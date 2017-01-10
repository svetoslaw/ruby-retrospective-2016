class Hash
  def fetch_deep(path)
    split_path = path.split('.')
    hash_dup = self.dup
    fetch_deep_hash(hash_dup, split_path)
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

  private
  
  def fetch_deep_helper(input, path)
    if input.is_a?(Hash)
      fetch_deep_hash(input, path)
    elsif input.is_a?(Array)
      fetch_deep_arr(input, path)
    end
  end
  
  def fetch_deep_hash(hash, path)
    hash = hash.keys_to_strings
    if path.length == 1
      hash[ path[0] ]
    else
      p = path.shift
      fetch_deep_helper(hash[ p ], path)
    end
  end
  
  def fetch_deep_arr(arr, path)
    if path.length == 1
      arr[ path[0].to_i ]
    else
      p = path.shift
      fetch_deep_helper(arr[ p.to_i ], path)
    end
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
end