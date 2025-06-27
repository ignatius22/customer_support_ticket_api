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

  let(:login_mutation) do
    <<~GQL
      mutation($email: String!, $password: String!) {
        login(input: {
          email: $email,
          password: $password
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

    data = json["data"]["signup"]

    expect(response).to have_http_status(:ok)
    expect(data["token"]).to be_present
    expect(data["errors"]).to be_empty
  end

  it "allows a user to log in with valid credentials" do
    user = User.create!(
      email: "agent@example.com",
      password: "strongpass123",
      name: "Agent Smith",
      role: "agent"
    )

    post "/graphql", params: {
      query: login_mutation,
      variables: {
        email: user.email,
        password: "strongpass123"
      }
    }

    json = JSON.parse(response.body)
    data = json["data"]["login"]

    expect(response).to have_http_status(:ok)
    expect(data["token"]).to be_present
    expect(data["errors"]).to be_empty
  end

  it "returns error for invalid credentials" do
    post "/graphql", params: {
      query: login_mutation,
      variables: {
        email: "wrong@example.com",
        password: "wrongpass"
      }
    }

    json = JSON.parse(response.body)
    data = json["data"]["login"]

    expect(data["token"]).to be_nil
    expect(data["errors"]).to include("Invalid credentials")
  end
end
