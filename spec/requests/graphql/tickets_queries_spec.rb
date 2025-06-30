require "rails_helper"

RSpec.describe "GraphQL Ticket Queries", type: :request do
  let(:customer) { User.create!(email: "customer@example.com", password: "securepass123", name: "Jane", role: "customer") }
  let(:agent)    { User.create!(email: "agent@example.com", password: "securepass123", name: "Bob", role: "agent") }

let!(:customer_ticket) { create(:ticket, title: "Customer's ticket", customer: customer) }
let!(:other_ticket) { create(:ticket, title: "Other's ticket", customer: create(:user, role: 'customer')) }

let!(:customer_tickets) do
  create_list(:ticket, 3, customer: customer)
end

  def auth_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  let(:my_tickets_query) do
    <<~GQL
      query($first: Int, $after: String) {
        myTickets(first: $first, after: $after) {
          edges {
            node {
              id
              title
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    GQL
  end

  let(:all_tickets_query) do
    <<~GQL
      query($first: Int, $after: String) {
        allTickets(first: $first, after: $after) {
          edges {
            node {
              id
              title
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
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

  it "allows a customer to view their own tickets with pagination" do
    # Create additional tickets for pagination testing
    3.times do |i|
      Ticket.create!(
        title: "Issue #{i}",
        description: "Details",
        customer: customer,
        status: :open
      )
    end

    # Test first page
    post "/graphql",
         params: {
           query: my_tickets_query,
           variables: JSON.generate({ first: 5 })
         },
         headers: auth_headers(customer)

    json = JSON.parse(response.body)

    edges = json.dig("data", "myTickets", "edges") || []
    page_info = json.dig("data", "myTickets", "pageInfo")

    expect(response).to have_http_status(:ok)
    expect(edges.length).to be > 0

    # Fetch page 2
    post "/graphql",
         params: {
           query: my_tickets_query,
           variables: JSON.generate({ first: 2, after: page_info['endCursor'] })
         },
         headers: auth_headers(customer)
    json = JSON.parse(response.body)

    expect(json.dig("data", "myTickets", "edges").length).to be > 0

    page_info = json.dig("data", "myTickets", "pageInfo")
    expect(page_info["hasNextPage"]).to be false
  end

    it "allows an agent to view all tickets with pagination" do
      # Create additional tickets for pagination testing
      5.times { |i| Ticket.create!(title: "Issue #{i}", description: "Details", customer: customer, status: :open) }

      # Test first page
      post "/graphql",
           params: {
             query: all_tickets_query,
             variables: JSON.generate({ first: 5 })
           },
           headers: auth_headers(agent)
      json = JSON.parse(response.body)

      edges = json.dig("data", "allTickets", "edges") || []
      page_info = json.dig("data", "allTickets", "pageInfo")

      expect(response).to have_http_status(:ok)
      expect(edges.length).to be > 0

      # Fetch page 2
      post "/graphql",
           params: {
             query: all_tickets_query,
             variables: JSON.generate({ first: 5, after: page_info['endCursor'] })
           },
           headers: auth_headers(agent)
      json = JSON.parse(response.body)

      page_info = json.dig("data", "allTickets", "pageInfo")
      edges = json.dig("data", "allTickets", "edges") || []
      expect(edges.length).to be > 0
      expect(page_info["hasNextPage"]).to be false
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
