Introduction
------------
This is a tiny wrapper around the SQLite C API that's written in RubyMotion. It is intentionally bare so as to limit the surface area of code that interacts with the raw C API (misuse of the C API can cause resource leaks and seg faults). Think of it more as a driver for SQLite than anything else.

Whenever possible, it uses Ruby idioms like blocks and exceptions.

Sample code
-----------

```ruby
db = SQLite3::Database.new(":memory:")
db.execute("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)")
db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["brad", 28])
db.execute("INSERT INTO test (name, age) VALUES (?, ?)", ["sparky", 24])

rows = []
db.execute("SELECT * FROM test") do |row|
  rows << row
end

rows.should == [
  { id: 1, name: "brad", age: 28 },
  { id: 2, name: "sparky", age: 24 }
]
```

Usage
----------
* Pass a filename to the constructor, or ":memory:". The database is held open for the lifetime of the object.
* Use `execute` to run SQL statements. All SQL statements are first prepared, and parameters can be passed as an Array or a Hash. If a Hash is passed, then the SQLite named parameter syntax is assumed to be in use.
* Use `execute_scalar` to run SQL statements and return the first column of the first row. This is useful for queries like `SELECT COUNT(*) FROM posts`.

Caveats
-------
* The way it links with libsqlite3.dylib is hacky: a blank .m file in the vendor. This makes it tough to depend on it from your own gem.

Status
----------
I don't use this code personally, so I'm not supporting it. Consider it a base for your own libraries.
