# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def render_unprocessable_entity_response(exception)
    render json: exception.record.errors, status: :unprocessable_entity
  end

  def render_not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def render_result(result)
    result.success do |subscription:|
      render json: subscription
    end
    result.failure do |message:, type:|
      validation_error(message, type)
    end
  end

  def validation_error(message, type)
    render json: {
      error:
          {
            message: message,
            type: type
          }

    }, status: :bad_request
  end
end
