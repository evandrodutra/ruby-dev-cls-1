require 'rails_helper'

RSpec.describe DirectoryBlueprint do
  let(:root) { create(:directory, name: 'Root') }
  
  before do
    root.files.attach(
      io: StringIO.new('test content'),
      filename: 'test.txt',
      content_type: 'text/plain'
    )
  end

  describe 'rendering' do
    subject { JSON.parse(DirectoryBlueprint.render(root)) }

    it 'includes basic attributes' do
      expect(subject).to include(
        'id' => root.id,
        'name' => 'Root'
      )
    end

    it 'includes files_data' do
      expect(subject['files_data']).to be_an(Array)
      expect(subject['files_data'].first).to include(
        'name' => 'test.txt'
      )
      expect(subject['files_data'].first['url']).to include('/rails/active_storage/blobs/')
    end

    context 'with subdirectories' do
      let!(:child) { create(:directory, name: 'Child', parent: root) }
      
      it 'includes depth information' do
        tree = JSON.parse(DirectoryBlueprint.render(Directory.find(root.id)))

        expect(tree['name']).to eq('Root')
        expect(tree['subdirectories'].size).to eq(1)
      end
    end
  end
end 
