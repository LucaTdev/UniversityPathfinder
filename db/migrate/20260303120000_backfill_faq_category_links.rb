class BackfillFaqCategoryLinks < ActiveRecord::Migration[8.0]
  class MigrationFaqCategory < ActiveRecord::Base
    self.table_name = "faq_categories"
  end

  class MigrationFaq < ActiveRecord::Base
    self.table_name = "faqs"
  end

  def up
    return unless table_exists?(:faq_categories) && table_exists?(:faqs)

    MigrationFaqCategory.reset_column_information
    MigrationFaq.reset_column_information

    general = MigrationFaqCategory.where("lower(name) = ?", "generale").first_or_create!(name: "Generale")

    now = Time.current
    MigrationFaq.where("categoria IS NULL OR btrim(categoria) = ''")
      .update_all(categoria: general.name, faq_category_id: general.id, updated_at: now)

    names =
      MigrationFaq
        .where.not(categoria: nil)
        .pluck(:categoria)
        .map { |c| c.to_s.strip.squish }
        .reject(&:blank?)
        .uniq

    names.each do |name|
      category = MigrationFaqCategory.where("lower(name) = ?", name.downcase).first_or_create!(name: name)
      MigrationFaq.where("btrim(categoria) = ?", name).update_all(faq_category_id: category.id, categoria: category.name, updated_at: now)
    end

    MigrationFaq.where(faq_category_id: nil).update_all(faq_category_id: general.id, categoria: general.name, updated_at: now)
  end

  def down
    # no-op
  end
end

