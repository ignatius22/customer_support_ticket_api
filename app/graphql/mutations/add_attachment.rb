# app/graphql/mutations/add_attachment.rb
module Mutations
  class AddAttachment < BaseMutation
    argument :ticket_id, ID, required: true
    argument :files, [ ApolloUploadServer::Upload ], required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(ticket_id:, files:)
      ticket = Ticket.find_by(id: ticket_id)
      return { ticket: nil, errors: [ "Ticket not found" ] } unless ticket

      files.each do |file|
        ticket.files.attach(io: file.to_io, filename: file.original_filename, content_type: file.content_type)
      end

      if ticket.save
        { ticket:, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
  end
end
