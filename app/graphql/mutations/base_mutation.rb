# app/graphql/mutations/base_mutation.rb
module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    protected

    def current_user
      context[:current_user]
    end

    def authorize!(condition, message = "Unauthorized")
      raise GraphQL::ExecutionError, message unless condition
    end

    def require_customer!
      user = current_user
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.customer?
      user
    end

    def require_agent!
      user = current_user
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.agent?
      user
    end

    def generate_token(user)
      payload = {
        user_id: user.id,
        exp: 24.hours.from_now.to_i
      }
      JWT.encode(payload, Rails.application.credentials.secret_key_base)
    end
  end
end
