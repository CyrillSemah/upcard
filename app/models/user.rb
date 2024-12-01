class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :cards, dependent: :destroy
  has_many :sent_invitations, through: :cards, source: :invitations

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :send_welcome_email

  # Instance Methods

  # Retourne le nom complet de l'utilisateur
  def full_name
    "#{first_name} #{last_name}".strip
  end

  # Vérifie si l'utilisateur a des cartes associées
  def has_cards?
    cards.exists?
  end

  private

  # Envoie un email de bienvenue à l'utilisateur
  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end
end
