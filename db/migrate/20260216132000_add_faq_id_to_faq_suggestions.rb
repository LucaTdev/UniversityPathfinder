class AddFaqIdToFaqSuggestions < ActiveRecord::Migration[8.0]
  def change
    add_reference :faq_suggestions, :faq, type: :integer, null: true, foreign_key: { on_delete: :nullify }
  end
end

