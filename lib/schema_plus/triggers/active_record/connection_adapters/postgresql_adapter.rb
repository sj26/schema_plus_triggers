# frozen_string_literal: true

module SchemaPlus::Triggers
  module ActiveRecord
    module ConnectionAdapters
      module PostgresqlAdapter
        def triggers(name = nil) #:nodoc:
          SchemaMonkey::Middleware::Schema::Triggers.start(connection: self, query_name: name, triggers: []) do |env|
            sql = <<-SQL
            SELECT relname as table_name, tgname as trigger_name
              FROM pg_trigger T
              JOIN pg_class C ON C.oid = T.tgrelid
            WHERE tgisinternal = FALSE
              AND relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false)))
            ORDER BY 1, 2
            SQL

            env.triggers += env.connection.query(sql, env.query_name).map { |row| [row[0], row[1]] }
          end.triggers
        end

        def trigger_definition(table_name, trigger_name, name = nil) #:nodoc:
          data = SchemaMonkey::Middleware::Schema::TriggerDefinition.start(connection: self, table_name: table_name, trigger_name: trigger_name, query_name: name) do |env|
            result = env.connection.query(<<-SQL, env.query_name)
            SELECT pg_get_triggerdef(T.oid)
              FROM pg_trigger T
              JOIN pg_class C ON C.oid = T.tgrelid
            WHERE tgisinternal = FALSE
              AND relnamespace IN (SELECT oid FROM pg_namespace WHERE nspname = ANY (current_schemas(false)))
              AND tgname = '#{quote_string(trigger_name)}'
              AND relname = '#{quote_string(table_name)}'
            SQL

            row = result.first
            unless row.nil?
              sql = row.first

              m = sql.match(/CREATE.+?TRIGGER\s+"?\w+"?\s+(.+?) ON\s+[\w\."]+\s+(.+)/)

              env.trigger    = m[1]
              env.definition = m[2]
            end
          end

          return data.trigger, data.definition
        end
      end
    end
  end
end

