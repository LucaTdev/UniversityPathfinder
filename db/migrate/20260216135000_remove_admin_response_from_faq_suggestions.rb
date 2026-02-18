class RemoveAdminResponseFromFaqSuggestions < ActiveRecord::Migration[8.0]
  def change
    remove_column :faq_suggestions, :admin_response, :text, if_exists: true
  end
end

