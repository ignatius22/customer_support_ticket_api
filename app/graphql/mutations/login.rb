module Mutations
  class Login < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :errors, [ String ], null: false

    def resolve(email:, password:)
      user = User.find_by(email:)

      if user&.authenticate(password)
        { token: generate_token(user), errors: [] }
      else
        { token: nil, errors: [ "Invalid credentials" ] }
      end
    end
  end
end
