class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(exception)
    Rails.logger.error("Record not found: #{exception.message}")
    render json: { error: "Record not found" }, status: :not_found
  end
end