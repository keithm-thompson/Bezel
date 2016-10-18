require_relative 'db_connection'

module Searchable
  def where(params)
    where_line = params.keys.map{|key| "#{key} = ?"}
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line.join(" AND ")}
    SQL
    parse_all(results)
  end


end
