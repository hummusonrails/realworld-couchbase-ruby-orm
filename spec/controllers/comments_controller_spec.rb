

require 'rails_helper'
require 'jwt'

RSpec.describe CommentsController, type: :controller do
  let(:current_user) do
    User.new(id: 'user-id', username: 'testuser', email: 'test@example.com',
             password_digest: BCrypt::Password.create('password'))
  end
  let(:article) do
    Article.new(id: 'article-id', slug: 'test-title', title: 'Test Title', description: 'Test Description',
                body: 'Test Body', tag_list: 'tag1,tag2', author_id: current_user.id)
  end
  let(:comment) do
    Comment.new(id: 'comment-id', body: 'Test Comment', author_id: current_user.id, article_id: article.id,
                type: 'comment')
  end
  let(:token) { JWT.encode({ user_id: current_user.id }, Rails.application.secret_key_base) }

  before do
    allow_any_instance_of(Comment).to receive(:save).and_return(true)
    allow_any_instance_of(Article).to receive_message_chain(:comments, :find).with('comment-id') { comment }
    allow(User).to receive(:find).and_return(current_user)
    allow(JWT).to receive(:decode).and_return([{ 'user_id' => current_user.id }])
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:authenticate_user).and_return(true)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #index' do
    it 'returns all comments for the article' do
      allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
      allow(article).to receive(:comments).and_return([comment])

      get :index, params: { article_id: 'test-title' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['comments'].first['body']).to eq('Test Comment')
    end
  end

  describe 'POST #create' do
    context 'when authenticated' do
      it 'creates a new comment for the article' do
        allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
        allow(article).to receive(:add_comment).with(instance_of(Comment)).and_return(true)
        allow_any_instance_of(Comment).to receive(:save).and_return(true)

        post :create, params: { article_id: 'test-title', comment: { body: 'Test Comment' } }, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['comment']['body']).to eq('Test Comment')
      end

      it 'returns an error if the comment cannot be created' do
        allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
        allow(article).to receive(:add_comment).with(instance_of(Comment)).and_return(true)
        allow_any_instance_of(Comment).to receive(:save).and_return(false)
        allow_any_instance_of(Comment).to receive_message_chain(:errors, :full_messages).and_return(['Error message'])

        post :create, params: { article_id: 'test-title', comment: { body: 'Test Comment' } }, as: :json

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to include('Error message')
      end
    end

    context 'when not authenticated' do
      it 'returns an error' do
        allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
        allow(article).to receive(:add_comment).with(instance_of(Comment)).and_return(true)
        allow_any_instance_of(Comment).to receive(:save).and_return(false)
        request.headers['Authorization'] = nil

        post :create, params: { article_id: 'test-title', comment: { body: 'Test Comment' } }

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when authenticated' do
      it 'deletes the comment' do
        allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
        allow(Comment).to receive(:find).with('comment-id').and_return(comment)
        allow(comment).to receive(:destroy).and_return(true)

        delete :destroy, params: { article_id: 'test-title', id: 'comment-id' }

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when not authenticated' do
      it 'returns an error' do
        allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
        allow(Comment).to receive(:find).with('comment-id').and_return(comment)
        allow(comment).to receive(:destroy).and_return(false)
        current_user.id = 'other-user-id'
        request.headers['Authorization'] = nil

        delete :destroy, params: { article_id: 'test-title', id: 'comment-id' }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
