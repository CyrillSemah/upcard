class HomeController < ApplicationController
  # Détermine dynamiquement le layout à utiliser
  layout :determine_layout

  # Action pour la page d'accueil
  def home
    if user_signed_in?
      # Récupère les cartes de l'utilisateur connecté avec leurs templates associés
      @cards = current_user.cards.includes(:template).order(created_at: :desc)
    end
  end

  private

  # Méthode pour déterminer le layout utilisé
  def determine_layout
    # Si l'utilisateur est connecté, on utilise le layout 'application'
    # Sinon, on utilise le layout 'landing'
    user_signed_in? ? 'application' : 'landing'
  end
end
