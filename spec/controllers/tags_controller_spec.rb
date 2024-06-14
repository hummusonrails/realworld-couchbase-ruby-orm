

require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  let(:tag) { Tag.new(name: 'Example Tag', type: 'tag') }

  before do
    allow(Tag).to receive(:all).and_return([tag])
  end

  describe 'GET #index' do
    it 'returns all tags' do
      get :index, as: :json

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['tags']).to include('Example Tag')
    end
  end
end
