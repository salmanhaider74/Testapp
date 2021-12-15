module Common::Types
  class BaseField < GraphQL::Schema::Field
    argument_class BaseArgument
  end
end
