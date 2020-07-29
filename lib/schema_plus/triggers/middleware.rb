# frozen_string_literal: true

module SchemaPlus::Triggers
  module Middleware
    module Dumper
      module Tables
        # Dump
        def after(env)
          env.connection.triggers.each do |table_name, trigger_name|
            next if env.dumper.ignored?(table_name)
            trigger, definition = env.connection.trigger_definition(table_name, trigger_name)
            heredelim           = "END_TRIGGER_#{table_name.upcase}_#{trigger_name.upcase}"
            statement           = <<~ENDTRIGGER
                create_trigger "#{table_name}", "#{trigger_name}", "#{trigger}", <<-'#{heredelim}', :force => true
              #{definition}
                #{heredelim}

            ENDTRIGGER

            env.dump.final << statement
          end
        end
      end
    end

    module Schema
      module Triggers
        ENV = [:connection, :query_name, :triggers]
      end

      module TriggerDefinition
        ENV = [:connection, :table_name, :trigger_name, :query_name, :trigger, :definition]
      end
    end

    module Migration
      module CreateTrigger
        ENV = [:connection, :table_name, :trigger_name, :triggers, :definition, :options]
      end

      module DropTrigger
        ENV = [:connection, :table_name, :trigger_name, :options]
      end
    end
  end
end