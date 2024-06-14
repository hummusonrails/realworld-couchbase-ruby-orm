require 'couchbase-orm'

class Tag < CouchbaseOrm::Base
  attribute :name, :string
  attribute :type, :string

  validates :name, presence: true

  def save
    self.id ||= SecureRandom.uuid
    self.type = 'tag'

    super
  end

  def to_hash
    {
      id:,
      name:,
      type:
    }
  end
end
