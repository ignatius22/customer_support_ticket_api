puts "🌱 Seeding data..."

customer = User.find_or_create_by!(email: "customer@example.com") do |user|
  user.name = "Customer 1"
  user.role = :customer
  user.password = "password123"
end

agent = User.find_or_create_by!(email: "agent@example.com") do |user|
  user.name = "Agent 1"
  user.role = :agent
  user.password = "password123"
end

Ticket.find_or_create_by!(title: "App Crash", customer_id: customer.id) do |ticket|
  ticket.description = "The app crashes when I log in."
  ticket.status = :open
end

Comment.create!(
  content: "Hi, we're looking into this issue.",
  ticket: Ticket.first,
  user: User.find_by(role: "agent")
)

Comment.create!(
  content: "Thanks, I'll wait for your response.",
  ticket: Ticket.first,
  user: User.find_by(role: "customer")
)


puts "✅ Done seeding!"
