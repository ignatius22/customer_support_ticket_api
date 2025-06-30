class TicketsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find(ticket_params[:customer_id])

   unless user.role == "customer"
    return render json: { error: "Only Customer can create ticket" }, status: :forbidden
   end

    ticket = Ticket.new(ticket_params)

    if ticket.save
      render json: ticket, status: :created
    else
      render json: { errors: ticket.error.full_message }, status: :unprocessable_entity
    end
  end

  def index
    tickets = Ticket.all
    status_param = params[:status]

    # Apply filters
    if params[:customer_id].present?
      tickets = tickets.where(customer_id: params[:customer_id])
    end

    if status_param.present?
      # Convert string status to symbol and check if it's a valid status
      status_sym = status_param.downcase.to_sym
      if Ticket.statuses.key?(status_sym)
        tickets = tickets.where(status: Ticket.statuses[status_sym])
      end
    end

    # For agents, return all tickets. For customers, only return their tickets
    if current_user.role == "customer"
      tickets = tickets.where(customer_id: current_user.id)
    end

    # Apply pagination
    paginated_tickets = tickets.page(params[:page] || 1).per(params[:per_page] || 10)

    # Return paginated response
    render json: {
      tickets: paginated_tickets.map { |ticket|
        ticket.as_json.merge("id" => ticket.id)
      },
      meta: {
        current_page: paginated_tickets.current_page,
        total_pages: paginated_tickets.total_pages,
        total_count: paginated_tickets.total_count,
        next_page: paginated_tickets.next_page,
        prev_page: paginated_tickets.prev_page
      }
    }
  end


  def show
    ticket = Ticket.find(params[:id])
    render json: ticket, status: :ok
  rescue
    render json: { error: "Ticket not Found" }, status: :not_found
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :description, :customer_id, :status)
  end
end
