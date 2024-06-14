require 'couchbase-orm'

class Article < CouchbaseOrm::Base
  belongs_to :user
  has_many :comments, dependent: :destroy

  attribute :slug, :string
  attribute :title, :string
  attribute :description, :string
  attribute :body, :string
  attribute :tag_list, :string
  attribute :created_at, :time
  attribute :updated_at, :time
  attribute :author_id, :string
  attribute :favorites
  attribute :favorites_count, :integer, default: 0

  view :by_id, emit_key: :id
  view :by_slug, emit_key: :slug
  view :by_author_id, emit_key: :author_id
  view :by_article_id, emit_key: :id

  validates :slug, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :body, presence: true
  validates :tag_list, presence: true
  validates :author_id, presence: true

  def save
    self.id ||= SecureRandom.uuid
    self.slug ||= generate_slug(title)

    super
  end

  def to_hash
    {
      id:,
      slug:,
      title:,
      description:,
      body:,
      tag_list:,
      created_at:,
      updated_at:,
      author_id:,
      favorites:,
      favorites_count:
    }
  end

  def update(attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    save
  end

  def self.find_by_slug(slug)
    find_by(slug:)
  end

  def comments
    Comment.where(article_id: id)
  end

  def add_comment(comment)
    comment = Article.comments.new(comment)
    comment.save
  end

  def add_tag(tag)
    tag_list << tag
    save
  end

  def remove_tag(tag)
    tag_list.delete(tag)
    save
  end

  def generate_slug(title)
    return nil if title.nil?

    @generate_slug ||= title.parameterize(separator: '-')
  end

  def author
    User.find(author_id)
  end
end
