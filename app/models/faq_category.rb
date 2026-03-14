class FaqCategory < ApplicationRecord
  GENERAL_NAME = "Generale".freeze

  has_many :faqs, dependent: :nullify
  has_many :faq_suggestions, dependent: :nullify

  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :reassign_faqs_to_general, prepend: true
  before_destroy :prevent_destroy_general

  after_update :sync_faq_categoria, if: :saved_change_to_name?

  def self.general!
    where("lower(name) = ?", GENERAL_NAME.downcase).first_or_create!(name: GENERAL_NAME)
  end

  def general?
    name.to_s.strip.casecmp?(GENERAL_NAME)
  end

  private

  def normalize_name
    self.name = name.to_s.strip.squish
  end

  def prevent_destroy_general
    return unless general?

    errors.add(:base, "Non puoi eliminare la categoria predefinita.")
    throw :abort
  end

  def reassign_faqs_to_general
    return if general?

    general = self.class.general!
    now = Time.current
    Faq.where(faq_category_id: id).update_all(faq_category_id: general.id, categoria: general.name, updated_at: now)
  end

  def sync_faq_categoria
    now = Time.current
    Faq.where(faq_category_id: id).update_all(categoria: name, updated_at: now)
  end
end
