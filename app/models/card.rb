class Card < ApplicationRecord
  include HasCloudinaryImage
  include ActiveStorage::Attached::Model
  
  # Relations
  belongs_to :user
  belongs_to :template, optional: true
  has_many :invitations, dependent: :destroy
  has_one_attached :cover_image
  has_one_attached :image
  
  # Cloudinary images
  has_cloudinary_image :cover_image
  
  # Enums
  enum status: {
    draft: 0,
    published: 1,
    archived: 2
  }
  
  enum event_type: {
    wedding: 0,
    birthday: 1,
    party: 2,
    other: 3
  }
  
  # Validations
  validates :title, presence: true
  validates :event_date, presence: true
  validates :event_type, presence: true
  validates :status, presence: true
  validates :template, presence: true, unless: :draft?
  validates :image, presence: true
  
  # Scopes
  scope :active, -> { where(status: :published) }
  scope :upcoming, -> { where('event_date > ?', Time.current) }
  scope :past, -> { where('event_date <= ?', Time.current) }
  
  # Callbacks
  before_validation :set_default_status, on: :create
  after_create :generate_preview
  before_destroy :cleanup_images
  
  # Instance methods
  def publish!
    return false unless template.present?
    update(status: :published)
  end
  
  def archive!
    update(status: :archived)
  end
  
  def response_rate
    return 0 if invitations.empty?
    (invitations.responded.count.to_f / invitations.count * 100).round(2)
  end
  
  def image_url
    Rails.application.routes.url_helpers.url_for(image) if image.attached?
  end
  
  private
  
  def set_default_status
    self.status ||= :draft
  end
  
  def generate_preview
    return unless cover_image.attached?
    # Will implement preview generation with Cloudinary transformations
  end

  def cleanup_images
    destroy_cover_image
  end
end
