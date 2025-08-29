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

    # === Relazioni ===
    has_one :student_profile, dependent: :destroy
    has_one :admin_profile, dependent: :destroy

    private

    def cast_role_to_integer
        self.role = role.to_i if role.present?
    end
end
