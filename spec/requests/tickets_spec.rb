# spec/requests/tickets_spec.rb
require 'rails_helper'

RSpec.describe "Tickets", type: :request do
  def auth_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "POST /tickets" do
    let(:customer) { create(:user) }
    let(:agent) { create(:user, role: 'agent') }

    let(:valid_params) do
      {
        ticket: {
          title: "Login issue",
          description: "Cannot log into the app",
          customer_id: customer.id
        }
      }
    end

    it "creates a new ticket" do
      expect {
        post "/tickets", params: valid_params, headers: auth_headers(customer)
      }.to change(Ticket, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Login issue")
    end

    it 'allows customers to create tickets' do
      post '/tickets', params: valid_params, headers: auth_headers(customer)
      expect(response).to have_http_status(:created)
      expect(Ticket.last.title).to eq('Login issue')
    end

    it 'does not allow agents to create tickets' do
      post '/tickets', params: valid_params.merge(ticket: { customer_id: agent.id }), headers: auth_headers(agent)
      expect(response).to have_http_status(:forbidden)
      expect(Ticket.count).to eq(0)
    end
  end

  describe "GET /tickets" do
    let!(:customer) { create(:user) }
    let!(:tickets) { create_list(:ticket, 15, customer: customer) }

    it "returns paginated tickets" do
      get "/tickets", params: { page: 1, per_page: 5 }, headers: auth_headers(customer)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
    expect(json.dig("tickets").length).to eq(5)
      expect(json["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 3,
        "total_count" => 15
      )
      expect(json["meta"]["next_page"]).to eq(2)
      expect(json["meta"]["prev_page"]).to be_nil

      # Get second page
      get "/tickets", params: { page: 2, per_page: 5 }, headers: auth_headers(customer)
      json = JSON.parse(response.body)
    expect(json["tickets"].length).to eq(5)
      expect(json["meta"]).to include(
        "current_page" => 2,
        "next_page" => 3,
        "prev_page" => 1
      )

      # Get last page
      get "/tickets", params: { page: 3, per_page: 5 }, headers: auth_headers(customer)
      json = JSON.parse(response.body)
      expect(json["tickets"].length).to eq(5)
      expect(json["meta"]).to include(
        "current_page" => 3,
        "next_page" => nil,
        "prev_page" => 2
      )
    end

    it "uses default pagination when no parameters are provided" do
      get "/tickets", headers: auth_headers(customer)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["tickets"].length).to eq(10) # Default per_page
      expect(json["meta"]).to include(
        "current_page" => 1,
        "total_pages" => 2,
        "total_count" => 15
      )
    end
  end

  describe "GET /tickets/:id" do
    let!(:customer) { create(:user) }
    let!(:ticket) { create(:ticket, customer: customer) }

    it "returns ticket by ID" do
      get "/tickets/#{ticket.id}", headers: auth_headers(customer)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(ticket.id)
      expect(json["title"]).to eq(ticket.title)
    end
  end

  describe "GET /tickets with customer_id param" do
    let!(:customer) { create(:user) }
    let!(:other_customer) { create(:user) }
    let!(:ticket1) { create(:ticket, customer: customer) }
    let!(:ticket2) { create(:ticket, customer: customer) }
    let!(:ticket3) { create(:ticket, customer: other_customer) }

    it "returns only the tickets for the specified customer" do
      get "/tickets", params: { customer_id: customer.id }, headers: auth_headers(customer)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      tickets = json["tickets"]
      expect(tickets.length).to eq(2)
      expect(tickets.map { |t| t["id"] }).to contain_exactly(ticket1.id, ticket2.id)
    end
  end

  describe "GET /tickets?status=closed" do
    let(:agent) { create(:user, role: 'agent') }
    let(:customer1) { create(:user, role: 'customer') }
    let(:customer2) { create(:user, role: 'customer') }

    before do
      @open_ticket = create(:ticket, status: :open, agent: agent, customer: customer1)
      @closed_ticket = create(:ticket, title: 'Closed Ticket', status: :closed, agent: agent, customer: customer2)
      @open_ticket_other = create(:ticket, status: :open, agent: agent, customer: customer1)

      # Verify the tickets were created with correct statuses
      expect(Ticket.where(status: :closed).count).to eq(1)
      expect(Ticket.where(status: :open).count).to eq(2)
    end

    it "returns only tickets with the specified status" do
      get "/tickets", params: { status: "closed" }, headers: auth_headers(agent)

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      tickets = parsed["tickets"]
      expect(tickets.length).to eq(1)
      expect(tickets.first["status"]).to eq("closed")
    end
  end

  describe "GET /tickets role-based access" do
    let(:customer) { create(:user, role: 'customer') }
    let(:agent) { create(:user, role: 'agent') }

    let!(:customer_ticket) { create(:ticket, customer: customer) }
    let!(:other_ticket) { create(:ticket) }

    it 'allows customers to see only their tickets' do
      get "/tickets", params: { customer_id: customer.id }, headers: auth_headers(customer)
      parsed = JSON.parse(response.body)
      tickets = parsed["tickets"]

      expect(tickets.length).to eq(1)
      expect(tickets.first["id"]).to eq(customer_ticket.id)
    end

    it 'allows agents to see all tickets' do
      get "/tickets", params: { agent_id: agent.id }, headers: auth_headers(agent)
      parsed = JSON.parse(response.body)
      tickets = parsed["tickets"]

      expect(tickets.length).to eq(2)
    end
  end
end
