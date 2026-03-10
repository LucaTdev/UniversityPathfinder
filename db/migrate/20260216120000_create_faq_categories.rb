class CreateFaqCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :faq_categories do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :faq_categories, :name, unique: true
    add_index :faq_categories, :slug, unique: true
  end
end

