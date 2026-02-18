class AddCategoriaToFaqSuggestions < ActiveRecord::Migration[8.0]
  def change
    add_column :faq_suggestions, :categoria, :text
  end
end

