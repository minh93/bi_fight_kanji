class User < ActiveRecord::Base
  attr_accessor :remember_token

  enum role: [:normal, :admin, :teacher]

  before_save ->{self.email = email.downcase}
  before_create :default_role

  has_many :activities, dependent: :destroy
  has_many :lessons, dependent: :destroy
  has_many :results, through: :lessons

  has_many :following_relationships, class_name: "Relationship",
    foreign_key: "follower_id", dependent: :delete_all
  has_many :followers_relationships, class_name: "Relationship",
    foreign_key: "followed_id", dependent: :delete_all

  has_many :following, through: :following_relationships, source: :followed
  has_many :followers, through: :followers_relationships, source: :follower

  has_many :user_goals
  has_many :user_logs

  mount_uploader :avatar, AvatarUploader

  has_secure_password

  validates :email,
    format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
    presence: true, length: {maximum: 50},
    uniqueness: {case_sensitive: false}
  validates :password, allow_nil: true,
    length: {minimum: 5}
  validates :name, presence: true,
    length: {maximum: 50}
  validate :avatar_size
  scope :search, ->query{where "name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%"}
  scope :all_admin, ->{where "role = 1"}

  def User.digest string
    cost = if ActiveModel::SecurePassword.min_cost
      BCrypt::Engine::MIN_COST
    else
      BCrypt::Engine.cost
    end
    BCrypt::Password.create string, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end

  def follow other_user
    following_relationships.create followed_id: other_user.id
  end

  def unfollow other_user
    following_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following? other_user
    following.include? other_user
  end

  def default_role
    self.role = :normal
  end

  def block
    update_attributes blocked_at: Time.now
  end

  def unblock
    update_attributes blocked_at: nil
  end

  def blocked?
    !self.blocked_at.nil?
  end

  def update_role new_role
    update_attributes role: new_role
  end

  def reset_password
    update_attributes password_digest: User.digest(Settings.user.default_password)
  end

  def avatar_size
    if avatar.size > 5.megabytes
      errors.add(:avatar, "should be less than 5MB")
    end
  end
end
