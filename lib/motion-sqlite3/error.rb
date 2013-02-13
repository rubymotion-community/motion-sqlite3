module SQLite3
  class DatabaseError < RuntimeError
    def self.from_last_error(db)
      DatabaseError.new(sqlite3_errmsg(db.value))
    end
  end
end
