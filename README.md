Introduction
------------
This is a tiny wrapper around the SQLite C API that's written in RubyMotion. It is intentionally bare so as to limit the surface area of code that interacts with the raw C API (misuse of the C API can cause resource leaks and seg faults). Think of it more as a driver for SQLite than anything else.

Whenever possible, it uses Ruby idioms like blocks and exceptions.

[![Code Climate](https://codeclimate.com/github/rubymotion-community/motion-sqlite3.png)](https://codeclimate.com/github/rubymotion-community/motion-sqlite3) [![Build Status](https://travis-ci.org/rubymotion-community/motion-sqlite3.png?branch=master)](https://travis-ci.org/rubymotion-community/motion-sqlite3) [![Gem Version](https://badge.fury.io/rb/motion-sqlite3.png)](http://badge.fury.io/rb/motion-sqlite3)

Is it any good?
---------------
Yes.

Sample code
-----------

#### DB in memory

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

#### DB in your resources folder

```ruby
# File is stored in your /project/resources/ folder
db = SQLite3::Database.new(File.join(App.resources_path, "my_db.sqlite"))

rows = []
db.execute("SELECT * FROM test ORDER BY id") do |row|
	rows << row
end
```

*this code assumes you're using BubbleWrap for access to `App.resources_path`.

Usage
----------
* Pass a filename to the constructor, or ":memory:". The database is held open for the lifetime of the object.
* Use `execute` to run SQL statements. All SQL statements are first prepared, and parameters can be passed as an Array or a Hash. If a Hash is passed, then the SQLite named parameter syntax is assumed to be in use.
* Use `execute_debug` to see the SQL statement and paramaters passed in the REPL. You should not use this method in production.
* Use `execute_scalar` to run SQL statements and return the first column of the first row. This is useful for queries like `SELECT COUNT(*) FROM posts`.
