RSpec.shared_examples "requires authentication" do
  context "when user is not authenticated" do
    let(:headers) { {} }

    it "returns an authentication error" do
      subject
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
      expect(json["errors"][0]["message"]).to include("Authentication required")
    end
  end
end

RSpec.shared_examples "requires agent role" do
  context "when user is not an agent" do
    let(:current_user) { create(:user, :customer) }
    let(:headers) { { "Authorization" => "Bearer #{current_user.generate_token}" } }

    it "returns an authorization error" do
      subject
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
      expect(json["errors"][0]["message"]).to include("Only agents can")
    end
  end
end
