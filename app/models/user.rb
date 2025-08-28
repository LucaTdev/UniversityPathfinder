class User < ApplicationRecord
    has_secure_password

    validates :first_name, :last_name, :email, :registration_date, presence: true
    validates :email, uniqueness: true
    validates :password, length: { minimum: 8 }, if: -> { password.present? }
    validates :terms_accepted, inclusion: { in: [true], message: "deve essere accettato" }

    ROLE_BASE = 0
    ROLE_STUDENT = 1
    ROLE_ADMIN = 2

    def base?
        role == ROLE_BASE
    end

    def student?
        role == ROLE_STUDENT
    end

    def admin?
        role == ROLE_ADMIN
    end

    has_one :student_profile, dependent: :destroy
    has_one :admin_profile, dependent: :destroy
end
