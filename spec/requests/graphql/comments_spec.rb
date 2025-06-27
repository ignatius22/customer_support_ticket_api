# spec/requests/graphql/comments_spec.rb
require "rails_helper"

RSpec.describe "GraphQL Comments", type: :request do
  let(:query_comments) do
    <<~GQL
      query($ticketId: ID!) {
        comments(ticketId: $ticketId) {
          id
          content
          user {
            email
            role
          }
        }
      }
    GQL
  end

  let(:add_comment_mutation) do
    <<~GQL
      mutation($ticketId: ID!, $content: String!) {
        addComment(input: {
          ticketId: $ticketId,
          content: $content
        }) {
          comment {
            id
            content
          }
          errors
        }
      }
    GQL
  end

  let(:agent)    { create(:user, role: :agent, password: "securepass123", name: "Agent") }
  let(:customer) { create(:user, role: :customer, password: "securepass123", name: "Customer") }
  let(:ticket)   { create(:ticket, customer: customer, agent: agent) }

  def auth_headers(user)
    token = JWT.encode({ user_id: user.id }, Rails.application.credentials.secret_key_base)
    { "Authorization" => "Bearer #{token}" }
  end

  it "lists comments for a ticket" do
    create(:comment, ticket: ticket, user: agent, content: "Hello")
    create(:comment, ticket: ticket, user: customer, content: "Thanks")

    post "/graphql", params: {
      query: query_comments,
      variables: { ticketId: ticket.id }
    }, headers: auth_headers(customer)

    json = JSON.parse(response.body)
    data = json.dig("data", "comments")

    expect(data.length).to eq(2)
    expect(data.map { |c| c["content"] }).to include("Hello", "Thanks")
  end

  it "allows agent to comment on a ticket" do
    post "/graphql", params: {
      query: add_comment_mutation,
      variables: { ticketId: ticket.id, content: "Working on it." }
    }, headers: auth_headers(agent)

    json = JSON.parse(response.body)
    data = json.dig("data", "addComment")

    expect(data["comment"]["content"]).to eq("Working on it.")
    expect(data["errors"]).to be_empty
  end

  it "prevents customer from commenting before agent has commented" do
    post "/graphql", params: {
      query: add_comment_mutation,
      variables: { ticketId: ticket.id, content: "Any update?" }
    }, headers: auth_headers(customer)

    json = JSON.parse(response.body)
    data = json.dig("data", "addComment")

    expect(data["comment"]).to be_nil
    expect(data["errors"]).to include("Customer can only comment after agent has replied.")
  end

  it "allows customer to comment after agent has commented" do
    create(:comment, ticket: ticket, user: agent, content: "On it.")

    post "/graphql", params: {
      query: add_comment_mutation,
      variables: { ticketId: ticket.id, content: "Thanks!" }
    }, headers: auth_headers(customer)

    json = JSON.parse(response.body)
    data = json.dig("data", "addComment")

    expect(data["comment"]["content"]).to eq("Thanks!")
    expect(data["errors"]).to be_empty
  end
end
