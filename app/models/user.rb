class User < ApplicationRecord
  has_secure_password

  has_one_attached :file # Keep this if you need user avatars or similar single file attachments

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, on: :create # Add `on: :create` if password is not always required on update
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
end
