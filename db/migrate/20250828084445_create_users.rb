class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.date :registration_date
      t.integer :role  default: 0, null: false  # 0=altro, 1=studente, 2=admin
      t.boolean :terms_accepted

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
