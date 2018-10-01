class User < ApplicationRecord
  attr_accessor :password

  before_save :encrypt_password
  after_save :clear_password

  #EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :username, :presence => true, :uniqueness => true, :length => { :in => 3..20 }
  #validates :email, :presence => true, :uniqueness => true, :format => EMAIL_REGEX
  validates :password, :confirmation => true #password_confirmation attr
  validates_length_of :password, :in => 6..20, :on => :create
  validate :validate_password_entry

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password= BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def isCheckpoint?
    checkpoint = Distance.where('lower(longname) = lower(?)', username)
    !checkpoint.empty?
  end

  def clear_password
      self.password = nil
      self.password_confirmation = nil
  end

  def self.authenticate(username="", login_password="")
    user = User.find_by_username(username)

    if user && user.match_password(login_password)
      return user
    else
      return false
    end
  end   

  def match_password(login_password="")
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end

  def israceadmin?(year=DateTime.now.year.to_s)
    return !(Raceadmin.where('user_id = ? AND year = ?', id,year.to_s).empty?)
  end

  def validate_password_entry
    unless password.nil?
      if password_confirmation.nil? || password != password_confirmation
        errors.add(:password, "Passwords don't match")
        return false
      end
      if password.blank?
        errors.add(:password, "Passwords is blank")
        return false
      elsif password.size < 6 
        errors.add(:password, "Passwords is less than 6 characters")
        return false
      elsif password.size > 20
        errors.add(:password, "Passwords is greater than 20 characters")
        return false
      end
    end
    true
  end
end
