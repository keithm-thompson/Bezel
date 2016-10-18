require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @model_class = class_name.constantize
  end

  def table_name
    @table_name = model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name.to_s + "Id").underscore.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    @foreign_key = options[:foreign_key] || (self_class_name.to_s + "Id").underscore.to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    @prior_options = assoc_options
    @prior_options[name] = options

    define_method(options.class_name.downcase.to_sym) do
      foreign_key = send(options.foreign_key)
      the_class = options.model_class
      the_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self,  options)
    @prior_options = assoc_options
    if @prior_options[name.to_s.singularize.to_sym].nil?
      @prior_options[name.to_s.singularize.to_sym] = options
    else
      @prior_options[name.to_s.singularize.to_sym] << options
    end
    define_method(options.table_name.to_sym) do
      primary_key = send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @prior_options ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      search_by = send(through_options.foreign_key)

      results = DBConnection.execute(<<-SQL, search_by)
        SELECT
        #{source_options.table_name}.*
        FROM
        #{through_options.table_name}
        JOIN
        #{source_options.table_name} ON #{source_options.table_name}.#{source_options.primary_key.to_s} = #{through_options.table_name}.#{source_options.foreign_key.to_s}
        WHERE
        #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL
      source_options.model_class.new(results.first)
    end
  end

  def has_many_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name.to_s.singularize.to_sym]
      search_classes = through_options.model_class.where(through_options.foreign_key => send(source_options.primary_key))

      search_by = []
      search_classes.each do |classes|
        search_by << classes.send(source_options.primary_key)
      end

      results = DBConnection.execute(<<-SQL, *search_by)
        SELECT
        #{source_options.table_name}.*
        FROM
        #{through_options.table_name}
        JOIN
        #{source_options.table_name} ON #{source_options.table_name}.#{source_options.foreign_key.to_s} = #{through_options.table_name}.#{through_options.primary_key.to_s}
        WHERE
        #{through_options.table_name}.#{through_options.primary_key} IN (#{Array.new(search_by.length,"?").join(", ")})
        SQL
      results.map{|result| source_options.model_class.new(result)}
    end
  end
end
