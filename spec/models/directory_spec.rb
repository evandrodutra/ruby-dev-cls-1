require 'rails_helper'

RSpec.describe Directory, type: :model do
  describe 'associations' do
    let(:directory) { create(:directory) }
    let(:parent_directory) { create(:directory) }
    let(:child_directory) { create(:directory, parent: directory) }

    it 'has many attached files' do
      expect(directory).to respond_to(:files)
      expect(directory.files).to be_an(ActiveStorage::Attached::Many)
    end

    it 'belongs to an optional parent directory' do
      expect(directory).to respond_to(:parent)
      directory.parent = parent_directory
      expect(directory.parent).to eq(parent_directory)
      expect(directory.parent_id).to eq(parent_directory.id)
    end

    it 'has many subdirectories' do
      expect(directory).to respond_to(:subdirectories)
      directory.subdirectories << child_directory
      expect(directory.subdirectories).to include(child_directory)
    end

    it 'destroys dependent subdirectories' do
      directory.subdirectories << child_directory
      expect { directory.destroy }.to change(Directory, :count).by(-2)
    end
  end

  describe 'validations' do
    let(:directory) { build(:directory) }

    it 'requires a name' do
      directory.name = nil
      expect(directory).not_to be_valid
      expect(directory.errors[:name]).to include("can't be blank")
    end

    context 'name uniqueness within same parent' do
      let!(:existing_directory) { create(:directory, name: 'Test Dir') }

      it 'validates uniqueness of name within the same parent' do
        new_directory = build(:directory, name: existing_directory.name)
        expect(new_directory).not_to be_valid
        expect(new_directory.errors[:name]).to include('has already been taken')
      end

      it 'allows same name in different parents' do
        parent1 = create(:directory)
        parent2 = create(:directory)

        dir1 = create(:directory, name: 'Same Name', parent: parent1)
        dir2 = build(:directory, name: 'Same Name', parent: parent2)

        expect(dir2).to be_valid
      end

      it 'allows same name when one has no parent' do
        root_dir = create(:directory, name: 'Test')
        child_dir = build(:directory, name: 'Test', parent: create(:directory))

        expect(child_dir).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe '.roots' do
      let!(:root1) { create(:directory, name: 'Root1') }
      let!(:root2) { create(:directory, name: 'Root2') }
      let!(:child) { create(:directory, name: 'Child', parent: root1) }

      it 'returns only root directories' do
        expect(Directory.roots).to match_array([ root1, root2 ])
      end

      it 'returns roots ordered by name' do
        expect(Directory.roots.to_a).to eq([ root1, root2 ])
      end
    end
  end

  describe 'file attachments' do
    let(:directory) { create(:directory) }

    it 'can attach multiple files' do
      directory.files.attach(
        io: StringIO.new('test content 1'),
        filename: 'test1.txt',
        content_type: 'text/plain'
      )

      directory.files.attach(
        io: StringIO.new('test content 2'),
        filename: 'test2.txt',
        content_type: 'text/plain'
      )

      expect(directory.files).to be_attached
      expect(directory.files.count).to eq(2)
    end
  end
end
