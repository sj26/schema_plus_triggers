require 'schema_plus/core'

require_relative 'triggers/version'

# Load any mixins to ActiveRecord modules, such as:
#
#require_relative 'triggers/active_record/base'

# Load any middleware, such as:
#
# require_relative 'triggers/middleware/model'

SchemaMonkey.register SchemaPlus::Triggers
