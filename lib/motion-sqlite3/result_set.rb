module SQLite3
  class ResultSet
    def initialize(statement, handle)
      @statement = statement
      @handle = handle
    end

    def each(&block)
      until @statement.done?
        yield current_row

        @statement.step
      end
    end

    private

    def current_row
      row = {}

      column_count = sqlite3_column_count(@handle.value)
      0.upto(column_count - 1) do |i|
        name = sqlite3_column_name(@handle.value, i).to_sym
        type = sqlite3_column_type(@handle.value, i)

        case type
        when SQLITE_NULL
          row[name] = nil
        when SQLITE_TEXT
          row[name] = sqlite3_column_text(@handle.value, i)
        when SQLITE_BLOB
          row[name] = NSData.dataWithBytes(sqlite3_column_blob(@handle.value, i), length: sqlite3_column_bytes(@handle.value, i))
        when SQLITE_INTEGER
          row[name] = sqlite3_column_int64(@handle.value, i)
        when SQLITE_FLOAT
          row[name] = sqlite3_column_double(@handle.value, i)
        end
      end

      row
    end
  end
end
