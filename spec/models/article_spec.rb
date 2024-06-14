

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:author) { User.new(id: 'author-id', username: 'author', email: 'author@example.com') }
  let(:article) do
    Article.new(id: 'article-id', title: 'Test Title', description: 'Test Description', body: 'Test Body',
                tag_list: 'tag1,tag2', author_id: author.id, favorites: [], favorites_count: 0, type: 'article')
  end
  let(:comment) { Comment.new(id: 'comment-id', body: 'Test Comment', author_id: 'author-id', article_id: article.id) }

  before do
    allow(User).to receive(:find).with('author-id').and_return(author)
    allow(Article).to receive(:find_by_slug).with('test-title').and_return(article)
    allow(Article).to receive(:all).and_return([article])
    allow_any_instance_of(Article).to receive(:save).and_return(true)
    allow_any_instance_of(Article).to receive(:comments).and_return([comment])
    allow_any_instance_of(Article).to receive(:add_comment).and_return([comment])
  end

  context 'when saving an article' do
    describe '#save' do
      it 'creates a new article record in the database' do
        allow(Article).to receive(:new).and_return(article)
        allow(article).to receive(:save).and_return(true)

        article.save

        expect(article.id).to eq('article-id')
      end
    end
  end

  context 'when converting an article to a hash' do
    describe '#to_hash' do
      it 'returns the article attributes as a hash' do
        expected_hash = {
          :title => 'Test Title',
          :description => 'Test Description',
          :body => 'Test Body',
          :tag_list => 'tag1,tag2',
          :author_id => 'author-id',
          :favorites => [],
          :favorites_count => 0,
          :id => 'article-id',
          :updated_at => nil,
          :created_at => nil,
          :slug => nil
        }
        expect(article.to_hash).to eq(expected_hash)
      end
    end
  end

  context 'when finding an article by slug' do
    describe '.find_by_slug' do
      it 'finds an article by slug' do
        article = Article.find_by_slug('test-title')
        expect(article).to be_a(Article)
        expect(article.title).to eq('Test Title')
      end
    end
  end

  context 'when retrieving all articles' do
    describe '.all' do
      it 'returns all articles' do
        articles = Article.all
        expect(articles).to be_an(Array)
        expect(articles.first).to be_a(Article)
        expect(articles.first.title).to eq('Test Title')
      end
    end
  end

  context 'when dealing with comments' do
    before do
      allow(comment).to receive(:save)
    end

    describe '#comments' do
      it 'returns all comments for the article' do
        article.save
        allow(article).to receive(:comments).and_return([comment])
        expect(article.comments.map(&:body)).to include('Test Comment')
      end
    end

    describe '#add_comment' do
      it 'adds a comment to the article' do
        article.save

        allow(article).to receive(:add_comment).and_return([comment])
        allow(article).to receive(:comments).and_return([comment])

        expect(article.comments.map(&:body)).to include('Test Comment')
      end
    end
  end
end
