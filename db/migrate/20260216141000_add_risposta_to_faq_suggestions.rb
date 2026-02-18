class AddRispostaToFaqSuggestions < ActiveRecord::Migration[8.0]
  def change
    add_column :faq_suggestions, :risposta, :text
  end
end

