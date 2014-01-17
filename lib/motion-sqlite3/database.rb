module SQLite3
  class Database
    def initialize(filename)
      @handle = Pointer.new(::Sqlite3.type)
      @logging = false

      result = sqlite3_open(filename, @handle)
      raise SQLite3Error, sqlite3_errmsg(@handle.value) if result != SQLITE_OK
    end

    def execute(sql, params = nil, &block)
      raise ArgumentError if sql.nil?

      if @logging
        puts "   SQL: #{sql}"
        puts "Params: #{params}" if params && ! params.empty?
      end

      prepare(sql, params) do |statement|
        results = statement.execute

        if block_given?
          results.each do |result|
            yield result
          end
        else
          rows = []

          results.each do |result|
            rows << result
          end

          rows
        end
      end
    end

    def execute_scalar(*args)
      execute(*args).first.values.first
    end

    attr_accessor :logging

    def transaction(&block)
      execute("BEGIN TRANSACTION")

      begin
        result = yield
      rescue
        execute("ROLLBACK TRANSACTION")
        raise
      end

      execute("COMMIT TRANSACTION")

      result
    end

    private

    def prepare(sql, params, &block)
      statement = Statement.new(@handle, sql, params)
      result = nil

      begin
        result = yield statement

      ensure
        statement.finalize
      end

      result
    end
  end
end
