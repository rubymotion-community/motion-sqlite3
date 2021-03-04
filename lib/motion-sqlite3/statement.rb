module SQLite3
  class Statement
    def initialize(db, sql, params)
      @db = db
      @handle = Pointer.new(::Sqlite3_stmt.type)
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
      sqlite3_finalize(@handle.value_with_autorelease)
    end

    def step
      @result = sqlite3_step(@handle.value_with_autorelease)
      unless @result == SQLITE_DONE || @result == SQLITE_ROW
        raise SQLite3Error, sqlite3_errmsg(@db.value_with_autorelease)
      end
    end

    private

    def bind(params)
      case params
      when Hash
        params.each { |name, value| bind_parameter(name, value) }
      when Array
        params.each_with_index { |value, i| bind_parameter(i+1, value) }
      when NilClass
      else
        raise ArgumentError, "params must be either a Hash or an Array"
      end
    end

    def bind_parameter(name, value)
      index = column_index(name)

      case value
      when NilClass
        result = sqlite3_bind_null(@handle.value_with_autorelease, index)
      when String, Symbol
        result = sqlite3_bind_text(@handle.value_with_autorelease, index, value, -1, lambda { |arg| })
      when Integer
        result = sqlite3_bind_int64(@handle.value_with_autorelease, index, value)
      when Float
        result = sqlite3_bind_double(@handle.value_with_autorelease, index, value)
      when NSDatavalue
        result = sqlite3_bind_blob(@handle.value_with_autorelease, index, value.bytes, value.length, lambda { |arg| })
      else
        raise SQLite3Error, "unable to bind #{value} to #{name}: unexpected type #{value.class}"
      end

      raise SQLite3Error, sqlite3_errmsg(@db.value_with_autorelease) if result != SQLITE_OK
    end

    def column_index(name)
      index = 0

      case name
      when String, Symbol
        index = sqlite3_bind_parameter_index(@handle.value_with_autorelease, ":#{name}")
        raise SQLite3Error, "couldn't find index for #{name}!" if index == 0

      when Integer
        index = name
      end

      index
    end

    def prepare(sql)
      remainder = Pointer.new(:string)
      result = sqlite3_prepare_v2(@db.value_with_autorelease, sql, -1, @handle, remainder)
      raise SQLite3Error, sqlite3_errmsg(@db.value_with_autorelease) if result != SQLITE_OK
    end
  end
end
