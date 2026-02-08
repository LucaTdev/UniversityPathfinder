class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.string :title
      t.text :content
      t.string :category
      t.string :icon_class
      t.datetime :published_at

      t.timestamps
    end
  end
end
