# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'active_record'
require 'schema_plus_triggers'
require 'schema_dev/rspec'

SchemaDev::Rspec.setup

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.warnings = true
  config.around(:each) do |example|
    ActiveRecord::Migration.suppress_messages do
      begin
        example.run
      ensure
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Migration.drop_table table, force: :cascade
        end
      end
    end
  end
end

def define_schema(config = {}, &block)
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Migration.drop_table table, force: :cascade
      end
      instance_eval &block
    end
  end
end

def apply_migration(config = {}, &block)
  ActiveRecord::Schema.define do
    instance_eval &block
  end
end

SimpleCov.command_name "[ruby#{RUBY_VERSION}-activerecord#{::ActiveRecord.version}-#{ActiveRecord::Base.connection.adapter_name}]"
