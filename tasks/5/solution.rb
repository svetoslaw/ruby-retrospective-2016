module DataModelClassMethods
  def data_store(store = nil)
    if store == nil
      @data_store
    else
      @data_store = store
    end
  end

  def attributes(*args)
    if args.empty?
      @attributes
    else
      @attributes = [:id] if @attributes == nil
      generate_methods(:id)
      args.each do |attr_name|
        @attributes << attr_name
        generate_methods(attr_name)
      end
    end
  end

  def where(query = {})
    query.each do |attr_name, _|
      unless @attributes.include?(attr_name)
        raise DataModel::UnknownAttributeError, "Unknown attribute #{attr_name}"
      end
    end
    result = []
    @data_store.find(query).each do |record|
      result << self.new(record)
    end
    result
  end

  private

  def generate_methods(attr_name)
    attr_accessor attr_name
    finder_method = ('find_by_' + attr_name.to_s).to_sym
    define_singleton_method finder_method do |attr_value|
      where({attr_name => attr_value})
    end
  end
end

class DataModel
  extend DataModelClassMethods
  class DeleteUnsavedRecordError < RuntimeError; end
  class UnknownAttributeError < RuntimeError; end

  def initialize(initial_values = {})
    initial_values.each do |attr_name, attr_value|
      assign = attr_name.to_s.insert(0, '@').to_sym
      if self.class.attributes.include? attr_name
        self.instance_variable_set(assign, attr_value) 
      end
    end
  end

  def save
    query = {}
    self.class.attributes.each { |attr_name| query[attr_name] = self.send(attr_name) }
    if self.id == nil
      self.id = self.class.data_store.current_id
      query[:id] = self.id
      self.class.data_store.create(query)
    else
      self.class.data_store.update(self.id, query)
    end
    self
  end

  def delete
    if self.id == nil
      raise DataModel::DeleteUnsavedRecordError.new
    else
      self.class.data_store.delete({id: self.id})
      self.id = nil
    end
    self
  end

  def ==(other)
    if self.class == other.class
      return self.id == other.id if self.id && other.id
    end
    self.equal? other
  end
end

class ArrayStore
  attr_reader :storage, :current_id

  def initialize
    @storage = []
    @current_id = 1
  end

  def create(record)
    @current_id += 1
    @storage << record
  end

  def find(query)
    result = []
    @storage.each do |record|
      result << record if query.all? { |key, _| query[key] == record[key] }
    end
    result
  end

  def update(id, new_attributes)
    @storage.each do |record|
      if record[:id] == id
        new_attributes.each { |key, value| record[key] = value }
        break
      end
    end
  end

  def delete(query)
    @storage.reject! { |record| query.all? { |key, _| query[key] == record[key] } }
  end
end

class HashStore
  attr_reader :storage, :current_id

  def initialize
    @storage = {}
    @current_id = 1
  end

  def create(record)
    @current_id += 1
    @storage[record[:id]] = record
  end

  def find(query)
    result = []
    @storage.each do |_, record|
      result << record if query.all? { |key, _| query[key] == record[key] }
    end
    result
  end

  def update(id, new_attributes)
    @storage.each do |_, record|
      if record[:id] == id
        new_attributes.each { |key, value| record[key] = value }
        break
      end
    end
  end

  def delete(query)
    @storage.reject! { |_, record| query.all? { |key, _| query[key] == record[key] } }
  end
end