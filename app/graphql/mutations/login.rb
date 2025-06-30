module Mutations
  class Login < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :errors, [ String ], null: false
    field :user, Types::UserType, null: true

    def resolve(email:, password:)
      user = User.find_by(email:)

      if user&.authenticate(password)
        { token: generate_token(user), user: user, errors: [] }
      else
        { token: nil, user: nil, errors: [ "Invalid credentials" ] }
      end
    end
  end
end
