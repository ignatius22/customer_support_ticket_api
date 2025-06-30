class User < ApplicationRecord
  has_secure_password

  has_one_attached :file


  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }
  validate :password_strength
  validates :role, presence: true

  has_many :comments, dependent: :destroy


  has_many :tickets, foreign_key: :customer_id, dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :agent_id

  enum :role, { customer: 0, agent: 1 }

  def password_strength
    if password&.downcase&.include?("password")
      errors.add(:password, "is too weak")
    end
  end
  def generate_token
    JWT.encode({ user_id: id }, Rails.application.credentials.secret_key_base)
  end
end
