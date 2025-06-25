class FilesController < ApplicationController
  def create
    directory = Directory.find(params[:directory_id])

    if params[:files].blank?
      return render json: { error: "No files provided" }, status: :unprocessable_entity
    end

    directory.files.attach(params[:files])
    render json: { message: "Files uploaded successfully." }, status: :created
  rescue StandardError => e
    Rails.logger.error("Error uploading files: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    directory = Directory.find(params[:directory_id])

    attachment = directory.files.find(params[:id])
    attachment.purge
    render json: { message: "File deleted successfully." }
  rescue StandardError => e
    Rails.logger.error("Error deleting file: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end
