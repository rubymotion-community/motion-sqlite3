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

    def columns
      @result_columns ||= begin
        columns = {}

        count = sqlite3_column_count(@handle.value)
        0.upto(count-1) do |i|
          name = sqlite3_column_name(@handle.value, i).to_sym
          type = sqlite3_column_type(@handle.value, i)

          columns[name] = ColumnMetadata.new(i, type)
        end

        columns
      end
    end

    def current_row
      row = {}

      columns.each do |name, metadata|
        case metadata.type
        when SQLITE_NULL
          row[name] = nil
        when SQLITE_TEXT
          row[name] = sqlite3_column_text(@handle.value, metadata.index)
        when SQLITE_BLOB
          row[name] = sqlite3_column_blob(@handle.value, metadata.index)
        when SQLITE_INTEGER
          row[name] = sqlite3_column_int(@handle.value, metadata.index)
        when SQLITE_FLOAT
          row[name] = sqlite3_column_double(@handle.value, metadata.index)
        end
      end

      row
    end
  end

  class ColumnMetadata < Struct.new(:index, :type); end
end
