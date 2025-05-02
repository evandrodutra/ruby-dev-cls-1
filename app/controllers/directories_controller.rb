class DirectoriesController < ApplicationController
  def create
    directory = Directory.new(directory_params)
    if directory.save
      render json: directory, status: :created
    else
      render json: directory.errors, status: :unprocessable_entity
    end
  end

  def index
    directories = Directory.roots.includes(:subdirectories, files_attachments: :blob)
    render json: DirectoryBlueprint.render(directories)
  end

  def show
    directory = Directory.where(id: params[:id]).includes(:subdirectories, files_attachments: :blob)
    render json: DirectoryBlueprint.render(directory)
  end

  def destroy
    directory = Directory.find(params[:id])
    directory.destroy
    render json: { message: "Directory deleted successfully" }, status: :ok
  end

  private

  def directory_params
    params.require(:directory).permit(:name, :parent_id)
  end
end
