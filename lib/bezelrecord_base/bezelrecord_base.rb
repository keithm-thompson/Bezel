require 'active_support/inflector'
require_relative '../../lib/db_connection'
require_relative 'associatable'
require_relative 'searchable'

class BezelrecordBase
  extend Associatable
  extend Searchable

  def self.columns
    unless @columns
      temp_columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = temp_columns.first.map { |column| column.to_sym }
    end
    @columns
  end

  def self.finalize!
    columns.each do |column|

      define_method("#{column}") do
        @attributes = self.attributes
        @attributes[column]
      end

      define_method("#{column}=") do |value|
        @attributes = self.attributes
        @attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    objects = results.map do |object|
      self.new(object)
    end
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
      LIMIT
        1
    SQL
    nil || object.map {|obj| self.new(obj)}.first
  end

  def initialize(params = {})
    table_columns = self.class.columns

    params.each do |key, value|
      raise "unknown attribute '#{key}'" unless table_columns.include?(key.to_sym)
      send("#{key}=",value)
    end
  end

  def attributes
  @attributes = @attributes || {}
  end

  def attribute_values
    table_cols = self.class.columns
    table_cols
    table_cols.map{ |col| self.send("#{col}")}
  end

  def insert
    columns = self.class.columns

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{columns.join(", ")})
      VALUES
        (#{Array.new(columns.length,"?").join(", ")})
      SQL
      self.send(:id=,DBConnection.last_insert_row_id)
  end

  def update
    DBConnection.execute(<<-SQL,*attribute_values[1..-1], attribute_values.first)
      UPDATE
        #{self.class.table_name}
      SET
        #{self.class.columns[1..-1].map{|col| "#{col} = ?"}.join(", ")}
      WHERE
        id = ?
      SQL

  end

  def save
    id.nil? ? insert : update
  end
end
