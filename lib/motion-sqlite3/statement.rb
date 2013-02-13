module SQLite3
  class Statement
    def initialize(db, sql, params)
      @db = db
      @handle = Pointer.new(Sqlite3_stmt.type)
      @result = nil

      prepare(sql)
      bind(params)
    end

    def done?
      @result == SQLITE_DONE
    end

    def execute
      step

      ResultSet.new(self, @handle)
    end

    def finalize
      sqlite3_finalize(@handle.value)
    end

    def step
      @result = sqlite3_step(@handle.value)
      unless @result == SQLITE_DONE || @result == SQLITE_ROW
        raise DatabaseError.from_last_error(@db)
      end
    end

    private
    def bind(params)
      case params
      when Hash
        params.each { |name, value| bind_parameter(name, value) }
      when Array
        params.each_with_index { |value, i| bind_parameter(i+1, value) }
      end
    end

    def bind_parameter(name, value)
      index = column_index(name)

      case value
      when NilClass
        result = sqlite3_bind_null(@handle.value, index)
      when String
        result = sqlite3_bind_text(@handle.value, index, value, -1, lambda { |arg| })
      when Integer
        result = sqlite3_bind_int(@handle.value, index, value)
      when Float
        result = sqlite3_bind_double(@handle.value, index, value)
      else
        raise DatabaseError, "unable to bind #{value} to #{name}: unexpected type #{value.class}"
      end

      raise DatabaseError, "unable to bind #{value} to #{name}" if result != SQLITE_OK
    end

    def column_index(name)
      index = 0

      case name
      when String, Symbol
        index = sqlite3_bind_parameter_index(@handle.value, ":#{name}")
        raise DatabaseError, "couldn't find index for #{name}!" if index == 0
      when Integer
        index = name
      end

      index
    end

    def prepare(sql)
      remainder = Pointer.new(:string)
      result = sqlite3_prepare_v2(@db.value, sql, -1, @handle, remainder)
      raise DatabaseError.from_last_error(@db) if result != SQLITE_OK
    end
  end
end
