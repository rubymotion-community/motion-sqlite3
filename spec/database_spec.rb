describe SQLite3::Database do
  before do
    @db = SQLite3::Database.new(":memory:")
  end

  describe "#execute" do
    it "raises an ArgumentError if sql is nil" do
      lambda { @db.execute(nil) }.should.raise(ArgumentError)
    end

    it "raises a DatabaseError when passed invalid SQL" do
      lambda { @db.execute("sadf") }.should.raise(SQLite3::DatabaseError)
    end

    it "allows parameters to be passed in as an Array" do
      @db.execute("CREATE TABLE test (name TEXT, address TEXT)")
      @db.execute("INSERT INTO test VALUES(?, ?)", ["matt", "123 main st"])

      @db.execute_scalar("SELECT changes()").should == 1
    end

    it "allows parameters to be passed in as a Hash" do
      @db.execute("CREATE TABLE test (name TEXT, address TEXT)")
      @db.execute("INSERT INTO test VALUES(:name, :address)", { name: "matt", address: "123 main st" })

      @db.execute_scalar("SELECT changes()").should == 1
    end    

    it "yields rows to the block" do
      @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)")
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["brad", 28])
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["sparky", 24])

      rows = []
      @db.execute("SELECT * FROM test") do |row|
        rows << row
      end

      rows.should == [
        { id: 1, name: "brad", age: 28 },
        { id: 2, name: "sparky", age: 24 }
      ]
    end
  end

  describe "#execute_scalar" do
    it "returns the first value of the first column" do
      @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)")
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["brad", 28])
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["sparky", 24])

      @db.execute_scalar("SELECT COUNT(*) FROM test WHERE age > ?", [20]).should == 2
    end
  end

  describe "#sqlite_version" do
    it "returns the version of SQLite in use" do
      @db.sqlite_version.should.not.be.nil
    end
  end

  describe "#transaction" do
    before do
      @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)")
    end

    it "commits transactions when the block succeeds" do
      @db.transaction do
        @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["herbert", 44])
      end

      @db.execute("SELECT * FROM test WHERE name = :name", { name: "herbert" }) do |row|
        row.should == { id: 1, name: "herbert", age: 44 }
      end
    end

    it "rolls back transactions if an exception is thrown" do
      begin
        @db.transaction do
          @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["herbert", 44])
          raise RuntimeError
        end
      rescue RuntimeError
      end

      called = false
      @db.execute("SELECT * FROM test WHERE name = :name", { name: "herbert" }) do |row|
        called = true
      end

      called.should.be.false
    end
  end
end
