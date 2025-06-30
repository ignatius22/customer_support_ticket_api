# spec/requests/graphql/attachments_spec.rb
require "rails_helper"

RSpec.describe "GraphQL Attachments", type: :request do
  let(:agent) { create(:user, role: :agent, password: "securepass123", name: "Agent") }
  let(:customer) { create(:user, role: :customer, password: "securepass123", name: "Customer") }
  let(:ticket) { create(:ticket, customer: customer, agent: agent) }

  let(:mutation) do
    <<~GQL
      mutation($ticketId: ID!, $files: [Upload!]!) {
        addAttachment(input: {
          ticketId: $ticketId,
          files: $files
        }) {
          ticket {
            id
            title
            fileUrls
          }
          errors
        }
      }
    GQL
  end

  it "allows uploading files to a ticket" do
    file = fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")

    post "/graphql",
      params: {
        operations: {
          query: mutation,
          variables: {
            ticketId: ticket.id,
            files: [ nil ] # this index will be replaced by map
          }
        }.to_json,
        map: { "0" => [ "variables.files.0" ] }.to_json,
        "0" => file
      },
      headers: {
        "Authorization" => "Bearer #{JWT.encode({ user_id: agent.id }, Rails.application.credentials.secret_key_base) }"
      }

    json = JSON.parse(response.body)

    data = json.dig("data", "addAttachment")

    expect(data["ticket"]).to be_present
    expect(data["ticket"]["fileUrls"]).not_to be_empty
    expect(data["errors"]).to be_empty
  end
end
