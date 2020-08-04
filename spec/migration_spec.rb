# frozen_string_literal: true

require 'spec_helper'

describe ActiveRecord::Migration do
  before do
    define_schema do
      create_table :user do |t|
        t.string :name, null: false
      end

      create_table :log do |t|
        t.string :operation
        t.string :log
      end

      # manual SQL so we do not need to depend on schema_plus_functions for testing
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
      execute 'DROP FUNCTION my_trigger_func() CASCADE'
    end
  end

  it "creates the trigger on the table" do
    apply_migration do
      create_trigger :user, :log_trigger, 'after insert or update or delete', 'for each row execute procedure my_trigger_func()'
    end

    expect(triggers('user')).to include(['user', 'log_trigger'])
  end

  protected

  def triggers(table)
    ActiveRecord::Base.connection.triggers.select { |(t, _)| t == table }
  end
end
