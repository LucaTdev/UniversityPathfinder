class CreateFavoriteRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :favorite_routes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :start_location
      t.string :end_location
      t.string :start_name
      t.string :end_name
      t.decimal :distance_km, precision: 8, scale: 2
      t.integer :duration_minutes
      t.string :transport_mode
      t.integer :search_count, default: 1

      t.timestamps
    end
    
    add_index :favorite_routes, [:user_id, :start_location, :end_location], unique: true, name: 'index_favorite_routes_on_user_and_locations'
  end
end