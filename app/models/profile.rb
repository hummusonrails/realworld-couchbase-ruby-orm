class Profile
  include ActiveModel::Model
  attr_accessor :id, :username, :email, :password_digest, :bio, :image, :following, :type, :favorites, :created_at, :updated_at

  def to_hash
    {
      'username' => username,
      'email' => email,
      'password_digest' => password_digest,
      'bio' => bio,
      'image' => image,
      'following' => following || [],
      'favorites' => favorites || [],
      'created_at' => created_at,
      'updated_at' => updated_at
    }
  end
end
