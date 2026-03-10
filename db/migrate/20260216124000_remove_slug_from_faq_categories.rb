class RemoveSlugFromFaqCategories < ActiveRecord::Migration[8.0]
  def change
    remove_index :faq_categories, :slug, if_exists: true
    remove_column :faq_categories, :slug, :string, if_exists: true
  end
end

