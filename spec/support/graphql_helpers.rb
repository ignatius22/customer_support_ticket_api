module GraphQLHelpers
  def jwt_for(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, ENV.fetch("RAILS_MASTER_KEY"))
  end
end

RSpec.configure do |config|
  config.include GraphQLHelpers
end
