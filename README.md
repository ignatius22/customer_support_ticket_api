
# 📨 Customer Support Ticketing API

A **Rails + GraphQL-based backend** for a customer support ticketing system with role-based access, ticket attachments, email notifications, and background job handling.

---

## 🚀 Tech Stack

- **Ruby on Rails 8**
- **PostgreSQL**
- **GraphQL** (`graphql-ruby`)
- **JWT Authentication**
- **Active Storage** (Cloudinary or local)
- **Solid Queue** (background jobs)
- **Action Mailer** (agent reminders)

---

## 🛠️ Setup Instructions

```bash
git clone <your-repo>
cd customer_support_ticketing_api

bundle install
rails db:setup
````

Create a `.env` file with:

```env
APP_HOST=http://localhost:3000
```

Then run:

```bash
rails server
```

---

## 🧪 Seed Demo Users

Run:

```bash
rails db:seed
```

This creates some test users with predefined roles and credentials.

---

## 👤 Test Users

| Role     | Email                   | Password        |
| -------- | ----------------------- | --------------- |
| Customer | `john@example.com`      | `password123`   |
| Agent    | `jane@example.com`      | `password123`   |
| Agent    | `agent@example.com`     | `strongpass123` |
| Customer | `customer1@example.com` | `strongpass123` |

> Use these credentials to test the login and role-specific functionality.

---

## 🔐 Authentication

Authenticate via GraphQL mutations:

### Sign Up

```graphql
mutation {
  signup(input: {
    email: "user@example.com",
    password: "password123",
    role: "customer"
  }) {
    token
    errors
  }
}
```

### Login

```graphql
mutation {
  login(input: {
    email: "john@example.com",
    password: "password123"
  }) {
    token
    errors
  }
}
```

> Add the token to request headers as:
> `Authorization: Bearer <token>`

---

## 🎟️ Ticket Operations

### Create Ticket

```graphql
mutation {
  createTicket(input: {
    title: "Login issue"
    description: "Can't login"
  }) {
    ticket {
      id
      title
    }
    errors
  }
}
```

### Fetch My Tickets

```graphql
query {
  myTickets {
    id
    title
    status
  }
}
```

---

## 📎 File Upload (Attachments)

Supports multiple file uploads via GraphQL:

```graphql
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
```

> Use `Content-Type: multipart/form-data` with a GraphQL client like **Altair**, **Postman**, or **Insomnia**.

---

## 📄 CSV Export (Agent Only)

Export closed tickets:

```graphql
mutation {
  exportClosedTickets {
    downloadUrl
    errors
  }
}
```

---

## 📬 Daily Email Reminder

Sends a summary email to agents with pending tickets.

Run manually:

```bash
rails runner 'DailyReminderJob.perform_now'
```

---

## ✅ Test Suite

```bash
bundle exec rspec
```

Includes tests for:

* Authentication
* Ticket creation & updates
* File upload logic
* CSV export
* GraphQL resolvers

---

## 🚀 Deployment

Compatible with:

* [Railway](https://railway.app/)
* [Render](https://render.com/)
* [Fly.io](https://fly.io/)
* Heroku (with minor tweaks)

---

## 👤 Author

Built and maintained by **Ignatius Sani**

