class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }
  validate :password_strength
  validates :role, presence: true

  has_many :comments, dependent: :destroy

  
  enum :role, { customer: 0, agent: 1}
 


  def password_strength
    if password&.downcase&.include?("password")
      errors.add(:password, "is too weak")
    end
  end
end
