describe SQLite3::Database do
  before do
    @db = SQLite3::Database.new(":memory:")
  end

  describe "#execute" do
    it "raises an ArgumentError if sql is nil" do
      lambda { @db.execute(nil) }.should.raise(ArgumentError)
    end

    it "raises a SQLite3Error when passed invalid SQL" do
      lambda { @db.execute("sadf") }.should.raise(SQLite3::SQLite3Error)
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

    it "returns rows if no block is provided" do
      @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)")
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["brad", 28])
      @db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["sparky", 24])

      @db.execute("SELECT * FROM test").should == [
        { id: 1, name: "brad", age: 28 },
        { id: 2, name: "sparky", age: 24 }
      ]
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

    it "handles results where the first row has a nil column correctly" do
      @db.execute 'create virtual table fts_1 using fts4 (col_1, col_2)'
      @db.execute "insert into fts_1 (col_1) values ('hello')"
      @db.execute "insert into fts_1 (col_2) values ('hello')"

      rows = @db.execute("select col_1, col_2 from fts_1 where fts_1 match 'hello' order by rowid")
      rows.size.should == 2
      one, two = rows

      one.should == { col_1: 'hello', col_2: nil }
      two.should == { col_1: nil, col_2: 'hello' }
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

  describe "#transaction" do
    it "commits the transaction if no error is raised" do
      @db.transaction do
        @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")
      end

      @db.execute_scalar("SELECT COUNT(*) FROM sqlite_master WHERE name = 'test'").should == 1
    end

    it "returns the value of the block" do
      @db.transaction do
        @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")

        42
      end.should == 42
    end

    it "aborts the transaction if an error is raised" do
      begin
        @db.transaction do
          @db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")
          @db.execute("INSERT INTO test (name) VALUES (?)", ["brad"])

          raise ArgumentError
        end

      rescue ArgumentError
      end

      @db.execute_scalar("SELECT COUNT(*) FROM sqlite_master WHERE name = 'test'").should == 0
    end
  end
end
