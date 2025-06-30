# app/mailers/daily_reminder_mailer.rb
class DailyReminderMailer < ApplicationMailer
  default from: "noreply@yourdomain.com"

  # Modify the method signature to accept arbitrary arguments and unpack them
  def open_tickets_reminder(*args_from_job)
    # Check if the arguments are wrapped in a hash with an :args key
    if args_from_job.is_a?(Array) && args_from_job.first.is_a?(Hash) && args_from_job.first.key?(:args)
      # This path is taken when MailDeliveryJob passes arguments like `{args: [agent_id, ticket_ids]}`
      actual_args = args_from_job.first[:args]
      agent_id = actual_args[0]
      open_ticket_ids = actual_args[1]
    elsif args_from_job.is_a?(Array) && args_from_job.length == 2 && args_from_job[0].is_a?(Integer) && args_from_job[1].is_a?(Array)
      # This path is for direct calls or simple deserialization where args are just [agent_id, ticket_ids]
      agent_id = args_from_job[0]
      open_ticket_ids = args_from_job[1]
    else
      # Fallback for unexpected argument structure (raise an error for debugging)
      raise ArgumentError, "Unexpected argument structure for open_tickets_reminder: #{args_from_job.inspect}"
    end

    # Add debugging lines if needed
    # Rails.logger.debug "Mailer args unpacked: agent_id=#{agent_id.inspect}, open_ticket_ids=#{open_ticket_ids.inspect}"
    # Rails.logger.debug "Attempting to find User with ID: #{agent_id}"

    # Re-fetch the agent and tickets using the unpacked IDs
    @agent = User.find(agent_id)
    @open_tickets = Ticket.where(id: open_ticket_ids)

    @app_host = Rails.application.routes.default_url_options[:host]
    @app_protocol = Rails.application.routes.default_url_options[:protocol] || "http"

    mail(to: @agent.email, subject: "Daily Reminder: You have #{@open_tickets.count} Open Tickets")
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "DailyReminderMailer: Failed to find agent or tickets. Error: #{e.message}, Agent ID: #{agent_id}, Ticket IDs: #{open_ticket_ids.inspect}"
    # Re-raise the error or handle it as appropriate for your application
    raise
  end
end
