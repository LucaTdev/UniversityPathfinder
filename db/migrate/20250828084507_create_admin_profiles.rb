class CreateAdminProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_profiles do |t|
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end
