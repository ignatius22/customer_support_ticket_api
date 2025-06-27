require "rails_helper"

RSpec.describe "GraphQL Ticket Queries", type: :request do
  let(:customer) { User.create!(email: "customer@example.com", password: "securepass123", name: "Jane", role: "customer") }
  let(:agent)    { User.create!(email: "agent@example.com", password: "securepass123", name: "Bob", role: "agent") }

  let!(:customer_ticket) { Ticket.create!(title: "Issue A", description: "Details", customer: customer) }
  let!(:other_ticket)    { Ticket.create!(title: "Issue B", description: "Details", customer: User.create!(email: "other@example.com", password: "securepass123", name: "Other", role: "customer")) }

  def auth_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:my_tickets_query) do
    <<~GQL
      query {
        myTickets {
          id
          title
        }
      }
    GQL
  end

  let(:all_tickets_query) do
    <<~GQL
      query {
        allTickets {
          id
          title
        }
      }
    GQL
  end

  let(:ticket_query) do
    <<~GQL
      query($id: ID!) {
        ticket(id: $id) {
          id
          title
        }
      }
    GQL
  end

  it "allows a customer to view their own tickets" do
    post "/graphql", params: { query: my_tickets_query }, headers: auth_headers(customer)
    json = JSON.parse(response.body)
    titles = json.dig("data", "myTickets").map { |t| t["title"] }

    expect(response).to have_http_status(:ok)
    expect(titles).to include("Issue A")
    expect(titles).not_to include("Issue B")
  end

  it "blocks agents from accessing myTickets" do
    post "/graphql", params: { query: my_tickets_query }, headers: auth_headers(agent)
    json = JSON.parse(response.body)
    expect(json["errors"].first["message"]).to eq("Unauthorized")
  end

  it "allows an agent to view all tickets" do
    post "/graphql", params: { query: all_tickets_query }, headers: auth_headers(agent)
    json = JSON.parse(response.body)
    expect(json["data"]["allTickets"].length).to eq(2)
  end

  it "blocks customers from viewing all tickets" do
    post "/graphql", params: { query: all_tickets_query }, headers: auth_headers(customer)
    json = JSON.parse(response.body)
    expect(json["errors"].first["message"]).to eq("Unauthorized")
  end

  it "allows agents to fetch any ticket by ID" do
    post "/graphql", params: { query: ticket_query, variables: { id: other_ticket.id } }, headers: auth_headers(agent)
    json = JSON.parse(response.body)
    expect(json.dig("data", "ticket", "id")).to eq(other_ticket.id.to_s)
  end

  it "allows a customer to fetch only their ticket" do
    post "/graphql", params: { query: ticket_query, variables: { id: customer_ticket.id } }, headers: auth_headers(customer)
    json = JSON.parse(response.body)
    expect(json.dig("data", "ticket", "id")).to eq(customer_ticket.id.to_s)
  end

  it "blocks a customer from fetching someone else’s ticket" do
    post "/graphql", params: { query: ticket_query, variables: { id: other_ticket.id } }, headers: auth_headers(customer)
    json = JSON.parse(response.body)
    expect(json["errors"].first["message"]).to eq("Unauthorized")
  end
end
