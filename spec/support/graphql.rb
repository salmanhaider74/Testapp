module GraphQLHelpers
  class Response
    attr_reader :data, :errors

    def initialize(args)
      @data = args['data'] || nil
      @errors = args['errors'] || nil
    end
  end

  def query(schema, query, variables: {}, context: {})
    converted = variables.deep_transform_keys! { |key| key.to_s.camelize(:lower) } || {}
    schema_klass = schema == :vendor ? VendorAppSchema : CustomerAppSchema
    response = schema_klass.execute(query, variables: converted, context: context, operation_name: nil)
    @response = Response.new(response.to_h)
  end

  def print_last_response
    puts @response.inspect
  end

  alias mutation query
end

RSpec.configure do |c|
  c.include GraphQLHelpers, type: :graphql
end
