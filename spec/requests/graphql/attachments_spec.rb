require "rails_helper"

RSpec.describe "GraphQL Attachments", type: :request do
  let(:agent) { create(:user, role: :agent) }
  let(:customer) { create(:user, role: :customer) }
  let(:ticket)   { create(:ticket, customer: customer, agent: agent) }

  before do
    ActiveStorage::Current.url_options = { host: "www.example.com", protocol: "https" }
    ActiveStorage::Blob.service = ActiveStorage::Service.configure(
      :cloudinary,
      Rails.application.config.active_storage.service_configurations
    )
  end


  let(:mutation) do
    <<~GQL
      mutation($ticketId: ID!, $files: [Upload!]!) {
        addAttachment(input: {
          ticketId: $ticketId,
          files: $files
        }) {
          ticket {
            id
            fileUrls
          }
          errors
        }
      }
    GQL
  end

  def auth_header_for(user)
    token = JWT.encode(
      { user_id: user.id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.secret_key_base
    )
    { "Authorization" => "Bearer #{token}" }
  end

  it "allows uploading files to a ticket" do
    file = fixture_file_upload(Rails.root.join("spec/fixtures/files/sample.pdf"), "application/pdf")

    operations = {
      query: mutation,
      variables: {
        ticketId: ticket.id.to_s,
        files: [ nil ]
      }
    }

    map = { "0" => [ "variables.files.0" ] }

    post "/graphql",
      params: {
        operations: operations.to_json,
        map: map.to_json,
        "0" => file
      },
      headers: auth_header_for(customer)

    json = JSON.parse(response.body)
    puts JSON.pretty_generate(json)

    expect(json["errors"]).to be_nil, -> {
      "Unexpected GraphQL error: #{json['errors']&.map { |e| e['message'] }.join(', ')}"
    }

    data = json.dig("data", "addAttachment")
    expect(data).not_to be_nil
    expect(data["ticket"]).to be_present
    expect(data["ticket"]["fileUrls"]).not_to be_empty
    expect(data["errors"]).to eq([])
  end
end
