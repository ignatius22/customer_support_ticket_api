require "rails_helper"

RSpec.describe "GraphQL Authentication", type: :request do
  let(:signup_mutation) do
    <<~GQL
      mutation($email: String!, $password: String!, $role: String!, $name: String!) {
        signup(input: {
          email: $email,
          password: $password,
          role: $role,
          name: $name
        }) {
          token
          errors
        }
      }
    GQL
  end

  it "allows a new user to sign up" do
    post "/graphql", params: {
      query: signup_mutation,
      variables: {
        email: "test@example.com",
        password: "strongpass123",
        role: "customer",
        name: "Test User"
      }
    }

    json = JSON.parse(response.body)
    puts JSON.pretty_generate(json) if json["errors"] # Optional: helpful during debugging

    expect(response).to have_http_status(:ok)
    expect(json["data"]).to be_present
    expect(json["data"]["signup"]).to be_present

    data = json["data"]["signup"]

    expect(data["token"]).to be_present
    expect(data["errors"]).to eq([])
  end
end
