class CreatePercorsis < ActiveRecord::Migration[8.0]
  def change
    create_table :percorsi do |t|
      t.string :partenza
      t.string :arrivo
      t.integer :utente
      t.decimal :lat
      t.decimal :long

      t.timestamps
    end
  end
end
