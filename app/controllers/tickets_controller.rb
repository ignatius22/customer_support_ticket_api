class TicketsController < ApplicationController
  def create

   user = User.find(ticket_params[:customer_id])

   unless user.role == "customer"
    return render json: {error: "Only Customer can create ticket" }, status: :forbidden
   end

    ticket = Ticket.new(ticket_params)

    if ticket.save
      render json: ticket, status: :created
    else
      render json: {errors: ticket.error.full_message}, status: :unprocessable_entity
    end
  end

  def index
    tickets = Ticket.all
  
    if params[:customer_id].present?
      tickets = tickets.where(customer_id: params[:customer_id])
    end
  
    if params[:status].present?
      tickets = tickets.where(status: params[:status].downcase)
    end
  
    render json: tickets
  end
  

  def show
    ticket = Ticket.find(params[:id])
    render json: ticket, status: :ok
  rescue
    render json: {error: "Ticket not Found"}, status: :not_found
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :description, :customer_id)
  end
end
