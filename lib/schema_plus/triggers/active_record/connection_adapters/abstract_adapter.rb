# frozen_string_literal: true

module SchemaPlus::Triggers
  module ActiveRecord
    module ConnectionAdapters
      module AbstractAdapter
        # Create a trigger.  Valid options are :force
        def create_trigger(table_name, trigger_name, triggers, definition, options = {})
          SchemaMonkey::Middleware::Migration::CreateTrigger.start(connection: self, table_name: table_name, trigger_name: trigger_name, triggers: triggers, definition: definition, options: options) do |env|
            table_name   = env.table_name
            trigger_name = env.trigger_name
            triggers     = env.triggers
            definition   = env.definition
            options      = env.options

            definition   = definition.to_sql if definition.respond_to? :to_sql
            if options[:force]
              drop_trigger(table_name, trigger_name, if_exists: true)
            end

            execute "CREATE TRIGGER #{quote_table_name(trigger_name)} #{triggers} ON #{quote_table_name(table_name)} #{definition}"
          end
        end

        # Remove a trigger.  Valid options are :if_exists
        # and :cascade
        #
        #    drop_trigger 'my_table', 'trigger_name', if_exists: true
        def drop_trigger(table_name, trigger_name, options = {})
          SchemaMonkey::Middleware::Migration::CreateTrigger.start(connection: self, table_name: table_name, trigger_name: trigger_name, options: options) do |env|
            table_name   = env.table_name
            trigger_name = env.trigger_name
            options      = env.options

            sql = "DROP TRIGGER"
            sql += " IF EXISTS" if options[:if_exists]
            sql += " #{quote_table_name(trigger_name)} ON #{quote_table_name(table_name)}"
            sql += " CASCADE" if options[:cascade]

            execute sql
          end
        end

        #####################################################################
        #
        # The functions below here are abstract; each subclass should
        # define them all. Defining them here only for reference.
        #

        # (abstract) Return the Trigger objects for triggers
        def triggers(name = nil)
          raise "Internal Error: Connection adapter did not override abstract function"
        end

        # (abstract) Return the Trigger definition
        def trigger_definition(table_name, trigger_name, name = nil)
          raise "Internal Error: Connection adapter did not override abstract function"
        end
      end
    end
  end
end