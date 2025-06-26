# Customer Support Ticketing API

This is a Rails + GraphQL-based backend API for a customer support ticketing system.

---

## 🚀 Tech Stack

* **Ruby on Rails 8**
* **PostgreSQL**
* **GraphQL (graphql-ruby)**
* **JWT Authentication**
* **Active Storage (for attachments)**
* **ActionMailer (for agent reminders)**

---

## 🛆 Setup Instructions

```bash
git clone <your-repo>
cd customer_support_ticketing_api

bundle install
rails db:setup
```

Add this to `.env` or your environment config:

```env
APP_HOST=http://localhost:3000
```

Then start the server:

```bash
rails s
```

---

## 🧲 Seed Demo Users

Run:

```bash
rails db:seed
```

Creates:

| Email                                       | Password    | Role     |
| ------------------------------------------- | ----------- | -------- |
| [john@example.com](mailto:john@example.com) | password123 | customer |
| [jane@example.com](mailto:jane@example.com) | password123 | agent    |

---

## 🔐 Authentication

Authenticate using the following GraphQL mutations:

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

> Use `Authorization: Bearer <token>` in headers for authenticated queries.

---

## 🗾️ Sample Queries

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

## 📄 CSV Export (Agent only)

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

Sends email to agents with open tickets.

Trigger manually:

```bash
rails runner 'DailyReminderJob.perform_now'
```

---

## 📌 File Upload (Attachments)

Upload files using a GraphQL client (e.g. Altair):

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

Set `Content-Type: multipart/form-data` and provide file uploads in Altair.

---

## ✅ Tests

```bash
bundle exec rspec
```

Covers:

* Model validations
* Auth
* Ticket logic
* CSV export
* GraphQL mutations/queries

---

## 🌐 Deployment

Deployable to platforms like:

* [Render](https://render.com/)
* [Fly.io](https://fly.io/)
* [Railway](https://railway.app/)

---

## 🧠 Author

Built by Ignatius Sani.
