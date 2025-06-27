# spec/requests/tickets_spec.rb
require 'rails_helper'

RSpec.describe "Tickets", type: :request do
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
        post "/tickets", params: valid_params
      }.to change(Ticket, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Login issue")
    end

    it 'allows customers to create tickets' do
      post '/tickets', params: valid_params
      expect(response).to have_http_status(:created)
      expect(Ticket.last.title).to eq('Login issue')
    end

    it 'does not allow agents to create tickets' do
      post '/tickets', params: valid_params.merge(ticket: { customer_id: agent.id })
      expect(response).to have_http_status(:forbidden)
      expect(Ticket.count).to eq(0)
    end
  end

  describe "GET /tickets" do
    let!(:customer) { create(:user) }
    let!(:tickets) { create_list(:ticket, 3, customer: customer) }

    it "returns all tickets" do
      get "/tickets"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.first).to have_key("title")
    end
  end

  describe "GET /tickets/:id" do
    let!(:customer) { create(:user) }
    let!(:ticket) { create(:ticket, customer: customer) }

    it "returns ticket by ID" do
      get "/tickets/#{ticket.id}"

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
      get "/tickets", params: { customer_id: customer.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json.map { |t| t["id"] }).to contain_exactly(ticket1.id, ticket2.id)
    end
  end

  describe "GET /tickets?status=closed" do
    let!(:agent) { create(:user) }
    let!(:customer1) { create(:user) }
    let!(:customer2) { create(:user) }

    let!(:open_ticket) { create(:ticket, status: "open", agent: agent, customer: customer1) }
    let!(:closed_ticket) { create(:ticket, status: "closed", agent: agent, customer: customer2) }

    it "returns only tickets with the specified status" do
      get "/tickets", params: { status: "closed" }

      expect(response).to have_http_status(:ok)
      parsed = JSON.parse(response.body)
      expect(parsed.length).to eq(1)
      expect(parsed.first["status"]).to eq("closed")
    end
  end

  describe "GET /tickets role-based access" do
    let(:customer) { create(:user, role: 'customer') }
    let(:agent) { create(:user, role: 'agent') }

    let!(:customer_ticket) { create(:ticket, customer: customer) }
    let!(:other_ticket) { create(:ticket) }

    it 'allows customers to see only their tickets' do
      get "/tickets", params: { customer_id: customer.id }
      parsed = JSON.parse(response.body)

      expect(parsed.length).to eq(1)
      expect(parsed.first["id"]).to eq(customer_ticket.id)
    end

    it 'allows agents to see all tickets' do
      get "/tickets", params: { agent_id: agent.id }
      parsed = JSON.parse(response.body)

      expect(parsed.length).to eq(2)
    end
  end
end
