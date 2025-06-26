class Ticket < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :agent, class_name: "User", optional: true

  has_many_attached :files
  has_many :comments, dependent: :destroy

  validates :title, :description, :customer, presence: true

  enum :status, { open: 0, in_progress: 1, closed: 2 }
end
