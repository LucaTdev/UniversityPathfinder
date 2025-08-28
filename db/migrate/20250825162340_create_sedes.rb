class CreateSedes < ActiveRecord::Migration[8.0]
  def change
    create_table :sedi do |t|
      t.string :nome
      t.string :indirizzo
      t.float :lat
      t.float :long

      t.timestamps
    end
  end
end
