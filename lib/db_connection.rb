require 'pg'
require 'yaml'

PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'
MIGRATIONS = Dir.glob('./db/migrate/*.sql').to_a

module Bezel
  class DBConnection
    def self.app_name
      YAML.load_file(Dir.pwd + '/config/database.yml')['database']
    end

    def self.add_to_version(file)
      name = parse_migration_file(file)
      execute(<<-SQL, [name])
        INSERT INTO
          version (name)
        VALUES
          ($1);
      SQL
    end

    def self.columns(table_name)
      columns = instance.exec(<<-SQL)
        SELECT
          attname
        FROM
          pg_attribute
        WHERE
          attrelid = '#{table_name}'::regclass AND
          attnum > 0 AND
          NOT attisdropped
      SQL

      columns.map { |col| col['attname'].to_sym }
    end

    def self.ensure_version_table
      table = nil

      if table.nil?
        execute(<<-SQL)
          CREATE TABLE IF NOT EXISTS version (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL
          );
        SQL
      end
    end

    def self.execute(*args)
      print_query(*args)
      instance.exec(*args)
    end

    def self.instance
      open if @db.nil?

      @db
    end

    def self.migrate
      ensure_version_table
      to_migrate = MIGRATIONS.reject { |file| migrated?(file) }
      to_migrate.each do |file|
        add_to_version(file)
        `psql -d #{app_name} -a -f #{file}`
      end
    end

    def self.migrated?(file)
      name = parse_migration_file(file)
      result = execute(<<-SQL, [name])
        SELECT
          *
        FROM
          version
        WHERE
          name = $1;
      SQL
      !!result.first
    end

    def self.parse_migration_file(file)
      filename = File.basename(file).split('.').first
      u_idx = filename.index('_')
      filename[0..u_idx - 1]
    end

    def self.print_query(query, *interpolation_args)
      return unless PRINT_QUERIES

      puts '--------------------'
      puts query
      unless interpolation_args.empty?
        puts "interpolate: #{interpolation_args.inspect}"
      end
      puts '--------------------'
    end

    def self.open
      @db = PG::Connection.new(
        dbname: app_name,
        port: 5432
      )
    end

    def self.reset
      commands = [
        "dropdb #{app_name}",
        "createdb #{app_name}"
      ]

      commands.each { |command| `#{command}` }
    end
  end
end
