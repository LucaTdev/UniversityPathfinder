class User < ApplicationRecord
    has_secure_password

    # Callback per normalizzare il ruolo
    before_validation :cast_role_to_integer

    # === Validazioni ===
    validates :first_name, :last_name, :email, :registration_date, presence: true
    validates :email, uniqueness: true
    validates :password, length: { minimum: 8 }, if: -> { password.present? }
    validates :terms_accepted, acceptance: true


    # === Costanti Ruoli ===
    ROLE_BASE = 0     # Altro
    ROLE_STUDENT = 1  # Studente
    ROLE_ADMIN = 2    # Admin

    # === Helpers Ruolo ===
    def base?
        role == ROLE_BASE
    end

    def student?
        role == ROLE_STUDENT
    end

    def admin?
        role == ROLE_ADMIN
    end

    # === Metodi per il profilo ===
    def full_name
        "#{first_name} #{last_name}".strip
    end

    def role_display
        case role
        when ROLE_STUDENT then "Studente"
        when ROLE_ADMIN then "Amministratore"
        else "Utente"
        end
    end

    def registration_year
        registration_date&.year || created_at&.year
    end

    def registration_month_year
        date = registration_date || created_at
        date&.strftime("%B %Y")
    end

    # Metodi per le statistiche (da implementare in base alle tue esigenze)
    def routes_count
        # Implementa il conteggio dei percorsi cercati dall'utente
        # Esempio: Route.where(user: self).count
        0 # Placeholder
    end

    def favorites_count
        favorite_routes.count
    end

    def top_favorite_routes
        favorite_routes.by_search_count.limit(3)
    end

    def notifications_count
        # Implementa il conteggio delle notifiche non lette
        # Esempio: Notification.where(user: self, read: false).count
        3 # Placeholder
    end

    # === Relazioni ===
    has_one :student_profile, dependent: :destroy
    has_one :admin_profile, dependent: :destroy
    has_many :routes, dependent: :destroy
    has_many :favorite_routes, dependent: :destroy

    private

    def cast_role_to_integer
        self.role = role.to_i if role.present?
    end
end
