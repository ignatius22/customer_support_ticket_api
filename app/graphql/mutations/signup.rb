require 'jwt'

module Mutations
  class Signup < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true

    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:, role:)
      return { token: nil, errors: ["Invalid role"] } unless %w[customer agent].include?(role)

      user = User.new(email:, password:, role:)

      if user.save
        { token: generate_token(user), errors: [] }
      else
        { token: nil, errors: user.errors.full_messages }
      end
    end
  end
end
