require 'rails_helper'

RSpec.describe FilesController, type: :controller do
  let(:directory) { create(:directory) }

  def mock_file(filename: "test.txt", content: "test content", content_type: "text/plain")
    file = Tempfile.new(filename)
    file.write(content)
    file.rewind
    fixture_file_upload(file.path, content_type)
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'attaches a single file to the directory' do
        expect {
          post :create, params: { 
            directory_id: directory.id, 
            files: [mock_file]
          }
        }.to change(ActiveStorage::Attachment, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('message' => 'Files uploaded successfully.')
      end

      it 'attaches multiple files to the directory' do
        expect {
          post :create, params: { 
            directory_id: directory.id, 
            files: [
              mock_file(filename: "file1.txt", content: "content 1"),
              mock_file(filename: "file2.txt", content: "content 2")
            ]
          }
        }.to change(ActiveStorage::Attachment, :count).by(2)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('message' => 'Files uploaded successfully.')
      end
    end

    context 'with invalid params' do
      it 'returns error when no files are provided' do
        post :create, params: { directory_id: directory.id }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error' => 'No files provided')
      end

      it 'returns error when directory does not exist' do
        post :create, params: { 
          directory_id: 'nonexistent', 
          files: [mock_file]
        }
        
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['error']).to include("Couldn't find Directory")
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:directory_with_file) { create(:directory) }
    
    before do
      directory_with_file.files.attach(mock_file)
    end

    context 'with valid params' do
      it 'deletes the file' do
        file_id = directory_with_file.files.first.id

        expect {
          delete :destroy, params: { 
            directory_id: directory_with_file.id, 
            id: file_id 
          }
        }.to change(ActiveStorage::Attachment, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => 'File deleted successfully.')
      end
    end

    context 'with invalid params' do
      it 'returns error when file does not exist' do
        delete :destroy, params: { 
          directory_id: directory_with_file.id, 
          id: 'nonexistent'
        }
        
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error when directory does not exist' do
        delete :destroy, params: { 
          directory_id: 'nonexistent', 
          id: 'some_id'
        }
        
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['error']).to include("Couldn't find Directory")
      end
    end
  end
end 