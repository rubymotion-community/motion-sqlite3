module SQLite3
  class Database
    def initialize(filename)
      @handle = Pointer.new(::Sqlite3.type)

      result = sqlite3_open(filename, @handle)
      raise SQLite3Error, sqlite3_errmsg(@handle.value) if result != SQLITE_OK
    end

    def execute(sql, params = nil, &block)
      raise ArgumentError if sql.nil?

      prepare(sql, params) do |statement|
        results = statement.execute

        if block_given?
          results.each do |result|
            yield result
          end
        end
      end
    end

    def execute_debug(*args, &block)
      puts "*** #{args[0]}"
      puts "    #{args[1].inspect}" if args[1]

      execute(*args, &block)
    end

    def execute_scalar(*args)
      result = {}

      execute(*args) do |row|
        result[:value] ||= row.values.first
      end

      result[:value]
    end

    private
    def prepare(sql, params, &block)
      statement = Statement.new(@handle, sql, params)

      begin
        yield statement

      ensure
        statement.finalize
      end
    end
  end
end
