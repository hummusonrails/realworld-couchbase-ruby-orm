require 'couchbase-orm'

class User < CouchbaseOrm::Base
  has_many :articles, dependent: :destroy
  has_many :comments

  attribute :username, :string
  attribute :email, :string
  attribute :password_digest, :string
  attribute :bio, :string
  attribute :image, :string
  attribute :type, :string
  attribute :following, default: []
  attribute :favorites, default: []
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :username, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true

  def to_hash
    {
      id:,
      username:,
      email:,
      bio:,
      image:,
      following:,
      favorites:,
      created_at:,
      updated_at:
    }
  end

  def save
    self.password_digest = BCrypt::Password.create(password_digest) if password_digest.present?
    self.id ||= SecureRandom.uuid
    super()
  end

  def update(attributes)
    attributes.each do |key, value|
      send("#{key}=", value)
    end
    save
  end

  def self.find_by_email(email)
    user = User.find_by(email:)
    raise StandardError, "Couldn't find User with 'email'=#{email}" unless user

    user
  end

  def self.find_by_username(username)
    user = User.find_by(username:)
    raise StandardError, "Couldn't find User with 'username'=#{username}" unless user

    user
  end

  def follow(user)
    user = User.find(user.id)
    raise StandardError, "Couldn't find User with 'id'=#{user.id}" if user.nil?

    return if following?(user)

    following << user.id
    save!
  end

  def unfollow(user)
    user = User.find(user.id)
    raise StandardError, "Couldn't find User with 'id'=#{user.id}" if user.nil?

    raise StandardError, "Couldn't find User with 'id'=#{user.id} in following list" unless following?(user)

    following.delete(user.id)
    save!
  end

  def following?(user)
    following.include?(user.id)
  end

  def favorited_articles
    articles = []
    favorites.map do |article_id|
      begin
        article = Article.find(article_id)
      rescue Couchbase::Error::DocumentNotFound
        article = nil
      end
      articles << article if article
    end

    if articles.empty?
      []
    else
      articles.flatten
    end
  end

  def favorite(article)
    raise StandardError, "Couldn't find Article with 'id'=#{article.id}" unless Article.find(article.id)
    return if favorited?(article)

    update(favorites: favorites << article.id)
    article.update(favorites_count: article.favorites_count + 1)
  end

  def unfavorite(article)
    raise StandardError, "Couldn't find Article with 'id'=#{article.id}" unless Article.find(article.id)
    raise StandardError, "Couldn't find Article with 'id'=#{article.id} in favorites list" unless favorited?(article)

    update(favorites: favorites - [article.id])
    article.update(favorites_count: article.favorites_count - 1)
  end

  def favorited?(article)
    if favorites.nil?
      false
    else
      favorites.include?(article.id)
    end
  end

  def favorited_by?(username)
    user = User.find_by_username(username)
    user.favorites.include?(id)
  end

  def articles
    articles = Article.find_by(author_id: id)
    if articles.nil?
      nil
    else
      [articles]
    end
  end

  def find_article_by_slug(slug)
    Article.find_by_slug(slug:)
  end

  def feed
    feed = Article.find_by(author_id: following)
    if feed.nil? || feed.empty?
      []
    else
      feed
    end
  end
end
