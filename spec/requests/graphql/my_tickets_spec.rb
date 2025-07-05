# require 'rails_helper'

# RSpec.describe 'myTickets query', type: :request do
#   let(:customer) { create(:user, role: :customer) }
#   let!(:tickets) { create_list(:ticket, 2, customer:) }

#   it 'returns tickets for the current customer' do
#     token = jwt_for(customer)

#     post "/graphql",
#          params: {
#            query: <<~GQL
#               query($page: Int, $perPage: Int) {
#                 myTickets(page: $page, perPage: $perPage) {
#                   tickets {
#                     id
#                     title
#                   }
#                   currentPage
#                   totalPages
#                   totalCount
#                 }
#               }
#            GQL
#            ,
#            variables: {
#              page: 1,
#              perPage: 10
#            }.to_json
#          },
#          headers: {
#            "Authorization" => "Bearer #{token}",
#            "Content-Type" => "application/json"
#          }

#     json = JSON.parse(response.body)
#     puts JSON.pretty_generate(json)

#     expect(json.dig("data", "myTickets", "tickets").length).to eq(2)
#     expect(json.dig("data", "myTickets", "currentPage")).to eq(1)
#     expect(json.dig("data", "myTickets", "totalCount")).to eq(2)
#   end
# end
