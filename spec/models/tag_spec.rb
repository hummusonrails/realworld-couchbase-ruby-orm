

require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { Tag.new(id: 'tag-id', name: 'Example Tag', type: 'tag') }

  before do
    allow(Tag).to receive(:find).with('tag-id').and_return(tag)
    allow(Tag).to receive(:all).and_return([tag])
  end

  describe '#save' do
    context 'when saving a new tag' do
      it 'creates a new tag in the database' do
        allow_any_instance_of(Tag).to receive(:save).and_return(true)

        tag.save

        expect(tag.id).to eq('tag-id')
      end
    end

    context 'when updating an existing tag' do
      it 'updates the tag in the database' do
        allow_any_instance_of(Tag).to receive(:save).and_return(true)

        tag.save

        tag.name = 'Updated Tag'

        tag.save

        expect(Tag.find(tag.id).name).to eq('Updated Tag')
      end
    end

    context 'when name is missing' do
      it 'raises an error' do
        tag = Tag.new(type: 'tag')
        expect(tag.save).to be_falsey
      end
    end
  end

  describe '#to_hash' do
    it 'returns a hash with name and type' do
      expect(tag.to_hash).to eq({ :name => 'Example Tag', :type => nil,  :id => 'tag-id' })
    end
  end
end
