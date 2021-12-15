class VendorAppSchema < GraphQL::Schema
  mutation(VendorApp::Types::MutationType)
  query(VendorApp::Types::QueryType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  rescue_from(StandardError) do |message|
    GraphQL::ExecutionError.new(message, extensions: { code: GraphqlHelper::ERRORS[:SERVER_ERROR] })
  end

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
