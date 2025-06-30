class GraphqlController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :execute ]
  def execute
    variables = ensure_hash(params[:variables])
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

    return nil unless auth_header&.start_with?("Bearer ")

    token = auth_header.split(" ").last

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

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      ambiguous_param.present? ? JSON.parse(ambiguous_param) : {}
    when Hash
      ambiguous_param
    when ActionController::Parameters
      ambiguous_param.to_unsafe_h
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
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
