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

  # --- NEW ADDITIONS FOR REMINDER SETTINGS ---
  has_one :reminder_setting, dependent: :destroy
  after_create :create_default_reminder_setting, if: :agent?
  # --- END NEW ADDITIONS ---

  def password_strength
    if password&.downcase&.include?("password")
      errors.add(:password, "is too weak")
    end
  end

  def generate_token
    JWT.encode({ user_id: id }, Rails.application.credentials.secret_key_base)
  end

  private

  # --- NEW METHOD FOR REMINDER SETTINGS ---
  def create_default_reminder_setting
    # Only create if the user is an agent and doesn't already have one
    # This ensures every new agent gets an enabled reminder setting by default
    build_reminder_setting(enabled: true).save! unless reminder_setting.present?
  end
  # --- END NEW METHOD ---
end
