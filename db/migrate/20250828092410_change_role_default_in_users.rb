class ChangeRoleDefaultInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :role, from: nil, to: 0
    change_column_null :users, :role, false, 0
  end
end
