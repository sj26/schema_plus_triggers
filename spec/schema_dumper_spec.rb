# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

describe "Schema dump" do
  before do
    define_schema do
      create_table :user do |t|
        t.string :name, null: false
      end

      create_table :log do |t|
        t.string :operation
        t.string :log
      end

      execute <<-SQL
CREATE OR REPLACE FUNCTION my_trigger_func() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO log (operation, log) VALUES ('DELETE', OLD.name);
  ELSEIF (TG_OP = 'UPDATE') THEN
    INSERT INTO log (operation, log) VALUES ('UPDATE', OLD.name || ' to ' || NEW.name);
  ELSEIF (TG_OP = 'INSERT') THEN
    INSERT INTO log (operation, log) VALUES ('INSERT', NEW.name);
  END IF; 
END;
$$
      SQL
    end
  end

  after do
    apply_migration do
      execute 'DROP FUNCTION my_trigger_func CASCADE'
    end
  end

  it "includes the trigger definition" do
    apply_migration do
      create_trigger :user, :log_trigger, 'after insert or update or delete', 'for each row execute procedure my_trigger_func()'
    end

    dump_schema.tap do |dump|
      expect(dump).to match(/create_trigger.+user.+log_trigger.+after insert/i)

      expect(dump).to match(/for each row.+my_trigger_func/i)
    end
    
  end

  protected

  def dump_schema(opts = {})
    stream = StringIO.new

    ActiveRecord::SchemaDumper.ignore_tables = Array.wrap(opts[:ignore]) || []
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)

    stream.string
  end
end
