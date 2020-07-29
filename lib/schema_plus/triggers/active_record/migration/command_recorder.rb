# frozen_string_literal: true

module SchemaPlus::Triggers
  module ActiveRecord
    module Migration
      module CommandRecorder
        def create_trigger(*args, &block)
          record(:create_trigger, args, &block)
        end

        def drop_trigger(*args, &block)
          record(:drop_trigger, args, &block)
        end

        def invert_create_trigger(args)
          [:drop_trigger, [args.first, args.second]]
        end
      end
    end
  end
end