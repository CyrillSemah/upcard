class Template < ApplicationRecord
  include HasCloudinaryImage
  
  # Relations
  has_many :cards
  has_one_attached :preview_image
  has_one_attached :background_image
  
  # Cloudinary images
  has_cloudinary_image :preview_image, :background_image
  
  # Enums
  enum category: {
    wedding: 0,
    birthday: 1,
    party: 2,
    cultural: 3,
    professional: 4,
    other: 5
  }
  
  # Validations
  validates :name, presence: true
  validates :category, presence: true
  validate :validate_images
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  
  # Callbacks
  before_validation :set_default_active, on: :create
  before_destroy :cleanup_images
  
  # Instance methods
  def deactivate!
    update(active: false)
  end
  
  def activate!
    update(active: true)
  end
  
  private
  
  def set_default_active
    self.active = true if active.nil?
  end

  def cleanup_images
    destroy_preview_image
    destroy_background_image
  end

  def validate_images
    if Rails.env.development?
      # En développement, on vérifie soit l'URL soit l'attachement
      unless preview_image.attached? || preview_image_url.present?
        errors.add(:preview_image, "can't be blank")
      end
      unless background_image.attached? || background_image_url.present?
        errors.add(:background_image, "can't be blank")
      end
    else
      # En production, on vérifie l'attachement
      errors.add(:preview_image, "can't be blank") unless preview_image.attached?
      errors.add(:background_image, "can't be blank") unless background_image.attached?
    end
  end
end
