module Mutations
  class AddComment < BaseMutation
    argument :ticket_id, ID, required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [ String ], null: false

    def resolve(ticket_id:, content:)
      authorize!(current_user.present?)

      ticket = Ticket.find_by(id: ticket_id)
      return { comment: nil, errors: [ "Ticket not found" ] } unless ticket

      if current_user.customer? && !agent_has_commented?(ticket)
        return {
          comment: nil,
          errors: [ "Customer can only comment after agent has replied." ]
        }
      end

      comment = Comment.new(content:, user: current_user, ticket:)

      if comment.save
        { comment:, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end

    private

    def agent_has_commented?(ticket)
      ticket.comments.any? { |comment| comment.user.agent? }
    end
  end
end
