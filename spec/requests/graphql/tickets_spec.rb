require "rails_helper"

RSpec.describe "GraphQL Tickets", type: :request do
  let(:mutation) do
    <<~GQL
      mutation($title: String!, $description: String!) {
        createTicket(input: {
          title: $title,
          description: $description
        }) {
          ticket {
            id
            title
            status
          }
          errors
        }
      }
    GQL
  end
  let(:customer) { User.create!(email: "customer@example.com", password: "securepass123", name: "Jane", role: "customer") }
  let(:agent)    { User.create!(email: "agent@example.com", password: "securepass456", name: "Bob", role: "agent") }


  def auth_header_for(user)
    token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  it "allows a customer to create a ticket" do
    post "/graphql",
      params: {
        query: mutation,
        variables: {
          title: "App Crash",
          description: "It crashes when I click login"
        }
      },
      headers: auth_header_for(customer)

    json = JSON.parse(response.body)
    data = json["data"]["createTicket"]

    expect(response).to have_http_status(:ok)
    expect(data["ticket"]["title"]).to eq("App Crash")
    expect(data["errors"]).to be_empty
  end

  it "rejects unauthenticated users" do
    post "/graphql",
      params: {
        query: mutation,
        variables: {
          title: "Test",
          description: "Should fail"
        }
      }

    json = JSON.parse(response.body)
    errors = json["errors"]
    expect(errors.first["message"]).to eq("Unauthorized")
  end

  it "rejects agents from creating tickets" do
    post "/graphql",
      params: {
        query: mutation,
        variables: {
          title: "Wrong user",
          description: "Agent should not be allowed"
        }
      },
      headers: auth_header_for(agent)

    json = JSON.parse(response.body)
    errors = json["errors"]
    expect(errors.first["message"]).to eq("Unauthorized")
  end
end
