require 'rails_helper'

RSpec.describe Directory, type: :model do
  describe 'associations' do
    it { should have_many_attached(:files) }
    it { should belong_to(:parent).class_name('Directory').optional }
    it { should have_many(:subdirectories).class_name('Directory').dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    describe 'name uniqueness' do
      subject { create(:directory) }
      it { should validate_uniqueness_of(:name).scoped_to(:parent_id) }
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
