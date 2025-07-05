module Mutations
  class AddAttachment < BaseMutation
    argument :ticket_id, ID, required: true
    argument :files, [ ApolloUploadServer::Upload ], required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(ticket_id:, files:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.customer?

      ticket = Ticket.find_by(id: ticket_id)
      return { ticket: nil, errors: [ "Ticket not found" ] } unless ticket

      files.each do |file|
        ticket.files.attach(
          io: file.tempfile,
          filename: file.original_filename,
          content_type: file.content_type
        )
      end

      { ticket: ticket, errors: [] }
    rescue => e
      { ticket: nil, errors: [ e.message ] }
    end
  end
end
