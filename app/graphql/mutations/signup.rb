require "jwt"

module Mutations
  class Signup < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true
    argument :name, String, required: true

    field :token, String, null: true
    field :errors, [ String ], null: false

    def resolve(email:, password:, role:, name:)
      unless %w[customer agent].include?(role)
        return { token: nil, errors: [ "Invalid role" ] }
      end

      user = User.new(email: email, password: password, role: role, name: name)

      if user.save
        token = generate_token(user)
        { token: token, errors: [] }
      else
        { token: nil, errors: user.errors.full_messages }
      end
    end

    private

    def generate_token(user)
      JWT.encode(
        { user_id: user.id, exp: 24.hours.from_now.to_i },
        Rails.application.credentials.secret_key_base,
        "HS256"
      )
    end
  end
end
