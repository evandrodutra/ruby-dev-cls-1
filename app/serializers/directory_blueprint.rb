class DirectoryBlueprint < Blueprinter::Base
  identifier :id

  fields :name

  field :files_data do |directory|
    directory.files.map do |file|
      {
        id: file.id,
        name: file.filename.to_s,
        url: Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
      }
    end
  end

  association :subdirectories, blueprint: DirectoryBlueprint
end
