require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs;'
    DB[:conn].execute(sql)
  end

  def save
    sql = 'INSERT INTO dogs(name, breed) VALUES(?,?);'
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute('SELECT * FROM dogs WHERE id = ?;', id)[0]
    Dog.new_from_db(dog)
  end

  def self.find_or_create_by(name:, breed:)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?;'

    dog = DB[:conn].execute(sql, name, breed)
    if dog.size != 0
      dog_data = dog[0]
      Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      song = self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = "
    SELECT *
    FROM dogs
    WHERE name = ?;
    "
    dog = DB[:conn].execute(sql, name).first
    Dog.new_from_db(dog)
  end

  def update
    sql = "
    UPDATE dogs
    SET name = ?,
    breed = ?,
    id = ?;
    "

    DB[:conn].execute(sql, name, breed, id)
  end
end
