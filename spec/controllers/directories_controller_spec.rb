require 'rails_helper'

RSpec.describe DirectoriesController, type: :controller do
  describe 'GET #index' do
    let!(:root1) { create(:directory, name: 'Root1') }
    let!(:root2) { create(:directory, name: 'Root2') }
    let!(:child) { create(:directory, name: 'Child', parent: root1) }

    it 'returns all root directories' do
      get :index
      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response.size).to eq(2)
      expect(json_response.map { |d| d['name'] }).to match_array([ 'Root1', 'Root2' ])
    end
  end

  describe 'GET #show' do
    let!(:root) { create(:directory, name: 'Root') }
    let!(:child) { create(:directory, name: 'Child', parent: root) }
    let!(:subchild) { create(:directory, name: 'SubChild', parent: child) }

    it 'returns the directory tree' do
      get :show, params: { id: root.id }
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response.first).to eq({
        "id" => root.id,
        "files_data" => [],
        "name" => "Root",
        "subdirectories" => [ {
          "id" => child.id,
          "files_data" => [],
          "name" => "Child",
          "subdirectories" => [ {
            "id" => subchild.id,
            "files_data" => [],
            "name" => "SubChild",
            "subdirectories" => []
          } ]
        } ]
      })
    end
  end

  describe 'DELETE #destroy' do
    let!(:root) { create(:directory, name: 'Root') }
    let!(:child) { create(:directory, name: 'Child', parent: root) }

    it 'deletes the directory and its children' do
      expect {
        delete :destroy, params: { id: root.id }
      }.to change(Directory, :count).by(-2)

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json_response).to eq({ 'message' => 'Directory deleted successfully' })
    end

    it 'returns not found if directory does not exist' do
      delete :destroy, params: { id: 999 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
