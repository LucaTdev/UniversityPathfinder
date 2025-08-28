class AddUserIdToStudentAndAdminProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :student_profiles, :user, null: false, foreign_key: true
    add_reference :admin_profiles, :user, null: false, foreign_key: true
  end
end
