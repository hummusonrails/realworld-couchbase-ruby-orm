require 'couchbase-orm'

class Comment < CouchbaseOrm::Base
  belongs_to :user
  belongs_to :article

  attribute :id, :string
  attribute :body, :string
  attribute :created_at, :time
  attribute :updated_at, :time
  attribute :author_id, :string
  attribute :article_id, :string

  view :by_id, emit_key: :id

  validates :body, presence: true
  validates :author_id, presence: true

  def save
    self.id ||= SecureRandom.uuid
    Comment.new(
      body:,
      created_at: Time.now,
      updated_at: Time.now,
      author_id:,
      article_id:
    )
    super
  end

  def to_hash
    {
      id:,
      body:,
      created_at:,
      updated_at:,
      author_id:,
      article_id:
    }
  end

  def author
    User.find(author_id)
  end
end
