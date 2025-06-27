class GraphqlController < ApplicationController
  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      current_user: current_user
    }

    result = CustomerSupportTicketingApiSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def current_user
    auth_header = request.headers["Authorization"]
    Rails.logger.debug "🔐 Header: #{auth_header.inspect}"

    return nil unless auth_header&.start_with?("Bearer ")

    token = auth_header.split(" ").last
    Rails.logger.debug "🧾 Token: #{token}"

    begin
      decoded = JWT.decode(
        token,
        Rails.application.credentials.secret_key_base,
        true,
        algorithm: "HS256"
      )
      user_id = decoded[0]["user_id"]
      user = User.find_by(id: user_id)
      Rails.logger.debug "👤 Current User: #{user&.email}"
      user
    rescue JWT::ExpiredSignature
      Rails.logger.debug "❌ Token has expired"
      nil
    rescue JWT::DecodeError => e
      Rails.logger.debug "❌ Decode Error: #{e.message}"
      nil
    end
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      variables_param.present? ? JSON.parse(variables_param) : {}
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: {
      errors: [ { message: e.message, backtrace: e.backtrace } ],
      data: {}
    }, status: 500
  end
end
