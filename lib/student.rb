require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id = nil,name,grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (? , ?)
    SQL
    DB[:conn].execute(sql,self.name,self.grade)
    if @id == nil
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql,self.name,self.grade,self.id)
    end #if 
  end #save
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  def self.new_from_db(array)
    student = self.new(array[0],array[1],array[2])
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name,self.grade,self.id)
  end
  
end