class CustomerSupportTicketingApiSchema < GraphQL::Schema
  # Configure GraphQL schema
  query Types::QueryType
  mutation Types::MutationType

  # Configure dataloader and limits
  use GraphQL::Dataloader
  max_complexity 300
  max_depth 20

  # Configure pagination
  default_max_page_size 50
  default_page_size 10

  # Configure connections
  def self.connection_class
    GraphQL::Types::Relay::BaseConnection
  end

  def self.edge_class
    GraphQL::Types::Relay::BaseEdge
  end

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Limit the size of incoming queries:
  max_query_string_tokens(5000)

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end
end
