class Invitation < ApplicationRecord
  # Relations
  belongs_to :card
  has_one :sender, through: :card, source: :user
  has_one :user, through: :card

  # Enums
  enum status: {
    pending: 0,
    sent: 1,
    delivered: 2,
    opened: 3,
    responded: 4,
    accepted: 5,
    declined: 6
  }
  
  # Validations
  validates :guest_email, presence: true, 
                         format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :guest_name, presence: true
  validates :status, presence: true
  validates :token, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :response, inclusion: { in: [true, false, nil] }
  
  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_default_status, on: :create
  after_create :send_invitation_email
  after_update :notify_card_owner, if: :status_changed?
  
  # Scopes
  scope :responded, -> { where.not(status: :pending) }
  scope :pending, -> { where(status: :pending) }
  scope :sent, -> { where(status: :sent) }
  scope :delivered, -> { where(status: :delivered) }
  scope :opened, -> { where(status: :opened) }
  scope :responded, -> { where(status: :responded) }
  scope :accepted, -> { responded.where(response: true) }
  scope :declined, -> { responded.where(response: false) }
  scope :accepted, -> { where(status: :accepted) }
  scope :declined, -> { where(status: :declined) }
  
  # Instance methods
  def accept!
    update(status: :accepted)
  end
  
  def decline!
    update(status: :declined)
  end
  
  def responded?
    !pending?
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_default_status
    self.status ||= :pending
  end
  
  def send_invitation_email
    InvitationMailer.invitation_email(self).deliver_later
  end
  
  def notify_card_owner
    # Will implement later
    # NotificationService.notify_status_change(self)
  end
end
