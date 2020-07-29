# frozen_string_literal: true

require 'schema_plus/core'

require_relative 'triggers/version'
require_relative 'triggers/active_record/connection_adapters/abstract_adapter'
require_relative 'triggers/active_record/migration/command_recorder'
require_relative 'triggers/middleware'

module SchemaPlus::Triggers
  module ActiveRecord
    module ConnectionAdapters
      autoload :PostgresqlAdapter, 'schema_plus/triggers/active_record/connection_adapters/postgresql_adapter'
    end
  end
end

SchemaMonkey.register SchemaPlus::Triggers