class CreateStudentProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :student_profiles do |t|
      t.string :email
      t.string :student_id
      t.string :university

      t.timestamps
    end
  end
end
