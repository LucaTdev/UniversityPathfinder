class FavoriteRoute < ApplicationRecord
  belongs_to :user
  
  validates :start_location, presence: true
  validates :end_location, presence: true
  validates :start_name, presence: true
  validates :end_name, presence: true
  
  # Limita a 3 percorsi preferiti per utente
  validate :max_favorites_per_user, on: :create
  
  scope :by_search_count, -> { order(search_count: :desc) }
  scope :recent, -> { order(updated_at: :desc) }
  
  # Incrementa il contatore quando il percorso viene cercato di nuovo
  def increment_search!
    increment!(:search_count)
    touch
  end
  
  private
  
  def max_favorites_per_user
    if user.favorite_routes.count >= 3
      errors.add(:base, "Hai raggiunto il limite di 3 percorsi preferiti")
    end
  end
end