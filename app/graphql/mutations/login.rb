module Mutations
  class Login < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(email:, password:)
      user = User.find_by(email: email)

      if user&.authenticate(password)
        token = generate_token(user)
        {
          token: token,
          user: user,
          errors: []
        }
      else
        {
          token: nil,
          user: nil,
          errors: [ "Invalid credentials" ]
        }
      end
    rescue => e
      {
        token: nil,
        user: nil,
        errors: [ e.message ]
      }
    end
  end
end
