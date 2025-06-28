require 'rails_helper'

RSpec.describe 'myTickets query', type: :request do
  let(:customer) { create(:user, role: :customer) }
  let!(:tickets) { create_list(:ticket, 2, customer:) }

  it 'returns tickets for the current customer' do
    token = jwt_for(customer)
    post "/graphql",
         params: {
           query: <<~GQL
             query {
               myTickets {
                 id
                 title
               }
             }
           GQL
         },
         headers: { "Authorization" => "Bearer #{token}" }

    json = JSON.parse(response.body)
    puts JSON.pretty_generate(json)
    expect(json.dig("data", "myTickets").length).to eq(2)
  end
end
