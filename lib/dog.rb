class Dog
  attr_accessor :name, :breed
  attr_accessor :id

  def initialize(**opts)
    # binding.pry
    @name, @breed = opts.values_at(:name, :breed)
    @id = nil
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    # binding.pry
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?,?)", self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    # self.class.new()
    # binding.pry
    self
  end

  def self.create(attrs)
    Dog.new(attrs).save
  end

  def self.find_by_id(id)

    att= DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    # binding.pry
    new_dog = Dog.new({name:att[1], breed:att[2]})
    new_dog.id=id
    new_dog
  end

  def self.find_or_create_by(dog)
    # binding.pry
    doge = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", dog[:name], dog[:breed])
    # binding.pry
    if !doge.empty?
      diggy_doge = self.new({name:doge[0][1], breed:doge[0][2]})
      diggy_doge.id = doge[0][0]
      # binding.pry
      diggy_doge
    else
      # binding.pry
      self.create(dog)
      # binding.pry
    end

  end

  def self.new_from_db(dog)
    # binding.pry
    new_dog = Dog.new({name:dog[1], breed:dog[2]})
    new_dog.id=dog[0]
    new_dog
  end

  def self.find_by_name(name)
    doge = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name)
    Dog.new_from_db(doge[0])
      # binding.pry
  end


  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

end
