class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  serialize :favorite_user_ids, Array

  MAX_PASSWORD_AGE = 30.days
  PASSWORD_STRENGTH_REGEX = /(?=.*[^\w])(?=.*[A-Z])(?=.*\d)./

  validates :password, format: {
    with: PASSWORD_STRENGTH_REGEX,
    message: "must include at least one uppercase letter, one special symbol and one digit"
  }, length: { minimum: 3, maximum: 50 }, allow_nil: true

  validate :prevent_old_password_reuse
  after_save :store_password, if: lambda { |user| user.password.present? }
  after_save :update_password_expiration_date!, if: lambda { |user| user.password.present? }

  has_many :old_passwords, class_name: 'AdminUserPassword'

  def name
    self.email
  end

  def password_expired?
    password_expire_at.nil? || Time.now > self.password_expire_at
  end

  def favorite_users
    User.where(id: favorite_user_ids)
  end

  def toggle_favorite_user(user_id)
    favorite_user_ids = (self.favorite_user_ids || [])
    user_id = user_id.to_i

    if favorite?(user_id)
      new_favorite_user_ids = favorite_user_ids.delete_if{|favorite| favorite == user_id}
    else
      new_favorite_user_ids = favorite_user_ids + [user_id]
    end
    update_attributes(favorite_user_ids: new_favorite_user_ids)

    new_favorite_user_ids
  end

  def favorite?(user)
    user_id = user.respond_to?(:id) ? user.id : user
    (favorite_user_ids || []).map(&:to_i).include?(user_id)
  end

  def prevent_old_password_reuse
    return true if password.blank?

    # check old passwords. passwords created in last day, can be reused
    last_passwords = old_passwords.order('created_at desc').limit(3)

    password_already_used = last_passwords.any? do |old_password|
      AdminUser.passwords_equal?(password, old_password.encrypted_password)
    end

    if password_already_used
      errors.add(:password, "you still can't use this previous password.")
      return false
    end
  end

  def update_password_expiration_date!
    update_column(:password_expire_at, MAX_PASSWORD_AGE.from_now)
    true
  end

  def store_password
    self.old_passwords.create(encrypted_password: self.encrypted_password)
    self.old_passwords.order('created_at desc').offset(3).each do |old_pass|
      old_pass.delete
    end
  end

  class << self
    def passwords_equal?(raw_password, encrypted_password = nil)
      return false if encrypted_password.blank?

      bcrypt   = ::BCrypt::Password.new(encrypted_password)
      password = ::BCrypt::Engine.hash_secret("#{raw_password}#{pepper}", bcrypt.salt)
      Devise.secure_compare(password, encrypted_password)
    rescue BCrypt::Errors::InvalidHash # if someone tryies to compare invalid has with password
      return false
    end
  end
end
